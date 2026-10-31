# odu's service (PR 134): the browser board, its CI runs, and its Nix binary
# cache, in one process, in server mode: odu's own door (GitHub App sign-in,
# sessions, roles) stands in front of the board, not the tailnet. The daemon
# binds the pod's address because the ingress reaches it through the Service.
# The operator's path (creating the App, first sign-in, tokens) is
# https://odu.kolu.dev/docs/#server-mode.
#
# The Ingress is still tailnet-only. Making it public (`tailscale.funnel`) is
# the last step, once the allow-list below has a real value: nothing may be
# public before the door is configured, and odu refuses to start with a
# partial or placeholder ODU_GITHUB_* set rather than admit the wrong people.
#
# The cache store is a chroot store on the PVC, not the host's /nix/store:
# `ODU_CACHE_STORE=local?root=…` keeps unsigned imports out of the host store
# and needs no trusted-user grant on the untrusted daemon the nix module exposes.
{ config, flake, lib, pkgs, ... }:
let
  inherit (flake) inputs;
  odu = inputs.odu.packages.${pkgs.stdenv.hostPlatform.system}.odu;
  namespace = "odu-k3s";
  port = 18440;
  # The operator appends the tailnet suffix to this short name. The GitHub
  # App's callback URL is this origin plus /auth/github/callback.
  tailHost = "odu-k3s.rooster-blues.ts.net";
  publicOrigin = "https://${tailHost}";
  # Who may sign in: `org:<name>`, `team:<org>/<slug>`, or GitHub logins,
  # comma-separated. Everyone admitted starts as a member; roles come from
  # `odu auth grant` with the root token. The value is the human's decision,
  # asked for in juspay/odu#134; this placeholder is deliberately not a login
  # or an org, so a deploy before the answer refuses sign-in rather than
  # guessing who belongs.
  githubAllow = "<ask-in-odu#134>";
  # The GitHub App's client secret, synced from 1Password to a Secret and
  # mounted as a file; odu reads the path, never the environment, for it.
  githubSecretDir = "/run/odu/github";
  labels = { app = "odu"; };
  image = "busybox:1.36.1@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662";
  app = config.k8s.apps.odu;
  dataMount = { name = "data"; mountPath = "/data"; };
in
{
  imports = [
    ../../modules
    ./secrets.nix
  ];

  k8s.apps.odu = {
    inherit namespace image;
    home = "/tmp";
    # The wrapper brings git/gh/just/openssh and the compressors; nix comes
    # from this module (the cache shells out to `nix`), as does /nix/store.
    # The package itself is here so `odu` is on the pod's PATH for `just apps
    # odu use`/`shell`; the Deployment uses the absolute path.
    packages = [ odu ];
    hardening.enable = true;
    nix.enable = true;
    network = {
      allowDNS = true;
      # The board serves; pushes come in through the Tailscale proxy. Outbound
      # HTTPS is for the GitHub App flow and membership checks, and for `gh`
      # when a run posts statuses.
      publicTCPPorts = [ 443 ];
    };
    tailscale = {
      enable = true;
      hostname = "odu-k3s";
      podPort = port;
      # Last step, after `githubAllow` is real: `funnel = true;` puts the
      # sign-in page on the public internet.
    };
    env = [
      { name = "ODU_STATE_DIR"; value = "/data/state"; }
      # A user-owned chroot store on the PVC. `null` (unset) would mean the
      # host daemon, which refuses unsigned imports from an untrusted user.
      { name = "ODU_CACHE_STORE"; value = "local?root=/data/cache-store"; }
      # The pod's address, not loopback: the Tailscale ingress reaches the
      # Service. `/` is the board, behind the door below.
      { name = "ODU_WEB_ORIGIN"; value = "http://0.0.0.0:${toString port}"; }
      { name = "ODU_PUBLIC_ORIGIN"; value = publicOrigin; }
      # Admit the browser Origin in case the ingress rewrites Host.
      { name = "ODU_WEB_ALLOWED_ORIGINS"; value = publicOrigin; }
      # Server mode: all three together, or odu refuses to start. The App is
      # created by hand (docs above); its credentials are the `odu-github-oauth`
      # item in the `Kubernetes` 1Password vault (see secrets.nix).
      {
        name = "ODU_GITHUB_CLIENT_ID";
        valueFrom.secretKeyRef = {
          name = "odu-github-oauth";
          key = "client_id";
          optional = false;
        };
      }
      { name = "ODU_GITHUB_CLIENT_SECRET_FILE"; value = "${githubSecretDir}/client_secret"; }
      { name = "ODU_GITHUB_ALLOW"; value = githubAllow; }
      { name = "SSL_CERT_FILE"; value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; }
      { name = "GIT_SSL_CAINFO"; value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; }
      { name = "TZDIR"; value = "${pkgs.tzdata}/share/zoneinfo"; }
      { name = "TZ"; value = config.time.timeZone; }
      # Bootstraps roles (`odu auth grant`); on a daemon with a door it is not
      # a principal and cannot start a run or read a bucket. External Secrets
      # syncs the 1Password item to this Secret; the pod waits for it.
      {
        name = "ODU_ROOT_TOKEN";
        valueFrom.secretKeyRef = {
          name = "odu-root-token";
          key = "token";
          optional = false;
        };
      }
    ];
    # The state directory and the chroot store must exist before the daemon
    # opens the cache database; the PVC's root is not 0700, and the cache's
    # SQLite holds every bucket's signing key. odu refuses to start unless its
    # daemon directory under the state dir is owner-only, so strip group/other
    # bits recursively there as well: a no-op when odu's umask made them, and
    # the repair when an fsGroup pass has widened them.
    initContainers = lib.mkBefore [
      {
        name = "odu-dirs";
        inherit image;
        securityContext = app.containerSecurityContext;
        command = [
          "/bin/sh"
          "-ec"
          ''
            umask 077
            mkdir -p /data/state /data/cache-store
            chmod 700 /data/state /data/cache-store
            chmod -R g-rwxs,o-rwx /data/state
          ''
        ];
        volumeMounts = [ dataMount ];
      }
    ];
    # HOME is /tmp, the hardening module's per-pod emptyDir. The daemon's gate
    # and control socket follow ODU_STATE_DIR, so both live on the PVC beside
    # the catalog and cache; /data/state is durable state, not pod scratch.
    volumeMounts = lib.mkBefore [
      dataMount
      { name = "github-oauth"; mountPath = githubSecretDir; readOnly = true; }
    ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "odu-data"; }
      {
        name = "github-oauth";
        secret = {
          secretName = "odu-github-oauth";
          defaultMode = 288; # 0440: readable through the pod's fsGroup.
        };
      }
    ];
  };

  services.k3s.manifests.odu.content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = { name = namespace; };
    }
  ] ++ app.manifests ++ [
    # local-path preserves data, but does not enforce the requested size.
    {
      apiVersion = "v1";
      kind = "PersistentVolumeClaim";
      metadata = { inherit namespace; name = "odu-data"; };
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "local-path";
        resources.requests.storage = "10Gi";
      };
    }

    {
      apiVersion = "apps/v1";
      kind = "Deployment";
      metadata = { inherit namespace; name = "odu"; labels = labels; };
      spec = {
        replicas = 1;
        # The cache's SQLite and chroot store are single-writer.
        strategy.type = "Recreate";
        selector.matchLabels = labels;
        template = {
          metadata.labels = labels;
          spec = {
            hostname = "odu-k3s";
            inherit (app) automountServiceAccountToken securityContext initContainers volumes;
            containers = [
              {
                name = "odu";
                inherit image;
                securityContext = app.containerSecurityContext;
                command = [ "${odu}/bin/odu" "web" ];
                inherit (app) env volumeMounts;
                ports = [{ name = "http"; containerPort = port; }];
                # Measured cache peaks are ~330 MiB; leave headroom without
                # turning a cache miss into a node-wide OOM.
                resources = {
                  requests = { memory = "512Mi"; cpu = "100m"; };
                  limits = { memory = "1Gi"; };
                };
                # The board's shell (the sign-in page, to an anonymous probe)
                # is the cheapest route that proves the service runtime, the
                # cache and the static bundle all loaded.
                readinessProbe = {
                  httpGet = { path = "/"; port = "http"; };
                  initialDelaySeconds = 2;
                  periodSeconds = 10;
                };
                livenessProbe = {
                  httpGet = { path = "/"; port = "http"; };
                  initialDelaySeconds = 30;
                  periodSeconds = 30;
                  timeoutSeconds = 5;
                };
              }
            ];
          };
        };
      };
    }

    {
      apiVersion = "v1";
      kind = "Service";
      metadata = {
        inherit namespace;
        name = "odu";
        labels = labels;
      };
      spec = {
        selector = labels;
        ports = [{ name = "http"; port = 80; targetPort = "http"; }];
      };
    }
  ];
}
