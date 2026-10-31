# odu's service (PR 133): the browser board, its CI runs, and its Nix binary
# cache, in one process. The upstream NixOS module puts this behind nginx on a
# loopback listener; here the Tailscale Ingress is the boundary, so the daemon
# binds the pod's address and the tailnet policy decides who may reach it.
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
  # The operator appends the tailnet suffix to this short name.
  tailHost = "odu-k3s.rooster-blues.ts.net";
  publicOrigin = "https://${tailHost}";
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
      # HTTPS is for `gh` when a run posts statuses.
      publicTCPPorts = [ 443 ];
    };
    tailscale = {
      enable = true;
      hostname = "odu-k3s";
      podPort = port;
    };
    env = [
      { name = "ODU_STATE_DIR"; value = "/data/state"; }
      # A user-owned chroot store on the PVC. `null` (unset) would mean the
      # host daemon, which refuses unsigned imports from an untrusted user.
      { name = "ODU_CACHE_STORE"; value = "local?root=/data/cache-store"; }
      # The pod's address, not loopback: the Tailscale ingress reaches the
      # Service, and tailnet policy is the access control. `/` is the board.
      { name = "ODU_WEB_ORIGIN"; value = "http://0.0.0.0:${toString port}"; }
      { name = "ODU_PUBLIC_ORIGIN"; value = publicOrigin; }
      # Admit the browser Origin in case the ingress rewrites Host.
      { name = "ODU_WEB_ALLOWED_ORIGINS"; value = publicOrigin; }
      { name = "SSL_CERT_FILE"; value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; }
      { name = "GIT_SSL_CAINFO"; value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; }
      { name = "TZDIR"; value = "${pkgs.tzdata}/share/zoneinfo"; }
      { name = "TZ"; value = config.time.timeZone; }
      # Admin verbs only (bucket create, token mint, gc). External Secrets
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
    volumeMounts = lib.mkBefore [ dataMount ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "odu-data"; }
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
                # The board's shell is the cheapest route that proves the
                # service runtime, the cache and the static bundle all loaded.
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
