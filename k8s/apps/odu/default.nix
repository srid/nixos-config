# odu's service (odu master): the browser board, its CI runs, and its Nix
# binary cache, in one process, in server mode: odu's own door (GitHub App sign-in,
# sessions, roles) stands in front of the board, not the tailnet. The daemon
# binds the pod's address because the ingress reaches it through the Service.
# The operator's path (creating the App, first sign-in, tokens) is
# https://odu.kolu.dev/docs/#server-mode.
#
# The Ingress is Tailscale Serve, so the board is on the tailnet only; bucket
# domains reach the public internet through the Cloudflare tunnel instead. odu
# refuses to start with a partial ODU_GITHUB_* set rather than admit the wrong
# people.
#
# The cache keeps each bucket's compressed NARs as files under the state dir on
# the PVC; it needs no Nix store.
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
  # `odu auth grant` with the root token. One login to start: a login list
  # needs no App installation, so it proves sign-in on the pod. `org:juspay`
  # follows once a Juspay org owner installs the App.
  githubAllow = "srid";
  # The GitHub App's client secret, synced from 1Password to a Secret and
  # mounted as a file; odu reads the path, never the environment, for it.
  githubSecretDir = "/run/odu/github";
  # The Cloudflare API token, synced and mounted the same way.
  cloudflareSecretDir = "/run/odu/cloudflare";
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
    # odu use`/`shell`; the Deployment uses the absolute path. The cloudflare
    # row spawns `cloudflared` from PATH, and odu's wrapper does not ship it.
    packages = [ odu pkgs.cloudflared ];
    hardening.enable = true;
    nix.enable = true;
    network = {
      allowDNS = true;
      # The board serves; pushes come in through the Tailscale proxy. Outbound
      # HTTPS is for the GitHub App flow and membership checks, the Cloudflare
      # API, and `gh` when a run posts statuses. 7844 is Cloudflare's tunnel
      # edge: `cloudflared` dials it over QUIC (UDP), falling back to HTTP/2
      # (TCP). All outbound; nothing listens for the tunnel.
      publicTCPPorts = [ 443 7844 ];
      publicUDPPorts = [ 7844 ];
    };
    tailscale = {
      enable = true;
      hostname = "odu-k3s";
      podPort = port;
    };
    env = [
      { name = "ODU_STATE_DIR"; value = "/data/state"; }
      # The pod's address, not loopback: the Tailscale ingress reaches the
      # Service. `/` is the board, behind the door below.
      { name = "ODU_WEB_ORIGIN"; value = "http://0.0.0.0:${toString port}"; }
      { name = "ODU_PUBLIC_ORIGIN"; value = publicOrigin; }
      # Admit the browser Origin in case the ingress rewrites Host.
      { name = "ODU_WEB_ALLOWED_ORIGINS"; value = publicOrigin; }
      # Server mode: all three together, or odu refuses to start. The App is
      # created by hand (docs above); its credentials are the `odu-github-app`
      # item in the `Kubernetes` 1Password vault (see secrets.nix).
      {
        name = "ODU_GITHUB_CLIENT_ID";
        valueFrom.secretKeyRef = {
          name = "odu-github-app";
          key = "client_id";
          optional = false;
        };
      }
      { name = "ODU_GITHUB_CLIENT_SECRET_FILE"; value = "${githubSecretDir}/client_secret"; }
      { name = "ODU_GITHUB_ALLOW"; value = githubAllow; }
      # The cloudflare row: one tunnel for this server, a route and proxied DNS
      # record per bucket domain, `cloudflared` as a child. Setting the file
      # mounts the row; an inactive token refuses it at boot.
      { name = "ODU_CLOUDFLARE_API_TOKEN_FILE"; value = "${cloudflareSecretDir}/api_token"; }
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
    # The state directory must exist before the daemon opens the cache
    # database; the PVC's root is not 0700, and the cache's
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
            mkdir -p /data/state
            chmod 700 /data/state
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
      { name = "github-app"; mountPath = githubSecretDir; readOnly = true; }
      { name = "cloudflare"; mountPath = cloudflareSecretDir; readOnly = true; }
    ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "odu-data"; }
      {
        name = "github-app";
        secret = {
          secretName = "odu-github-app";
          defaultMode = 288; # 0440: readable through the pod's fsGroup.
        };
      }
      {
        name = "cloudflare";
        secret = {
          secretName = "odu-cloudflare";
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
        # The cache's SQLite and object files are single-writer.
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
                # A public cache: concurrent pulls of large NARs have pushed it
                # past 2Gi. pureintent has 32 GB; the limit still keeps a
                # runaway from becoming a node-wide OOM.
                resources = {
                  requests = { memory = "1Gi"; cpu = "100m"; };
                  limits = { memory = "8Gi"; };
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
