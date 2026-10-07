# Learning example: browser → Tailscale HTTPS Ingress → Service → Deployment, with a PVC
# preserving data across pod restarts. This single-node setup runs olai from
# the host Nix store; BusyBox supplies the container root filesystem.
{ config, flake, lib, pkgs, ... }:
let
  inherit (flake) inputs;
  olai = inputs.olai.packages.${pkgs.stdenv.hostPlatform.system}.olai;
  agents = inputs.agent-distro.lib.mkLaunchers {
    inherit pkgs;
    profile = inputs.agent-distro.profiles.vanilla;
  };
  caBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  namespace = "olai-k3s";
  port = inputs.olai.lib.defaultPort;
  labels = { app = "olai"; };
  image = "busybox:1.36.1@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662";
  app = config.k8s.apps.olai;
  homeMount = { name = "data"; mountPath = app.home; };
in
{
  imports = [ ../../modules ./mail.nix ./secrets.nix ];

  k8s.apps.olai = {
    inherit namespace image;
    home = "/data";
    packages = [
      agents.claude
      agents.codex
      pkgs.just
      inputs.disc-scrape.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    hardening.enable = true;
    nix.enable = true;
    network = {
      allowDNS = true;
      # Public web/AI APIs, GitHub SSH, and Gmail SMTP/IMAP.
      publicTCPPorts = [ 80 443 22 465 587 993 ];
    };
    tailscale = {
      enable = true;
      hostname = "olai-k3s";
      podPort = port;
    };
    ssh = {
      enable = true;
      secretName = "olai-ssh";
      knownHosts = (import ../../known-hosts.nix).github;
    };
    git = {
      enable = true;
      url = "git@github.com:srid/Vault.git";
      directory = "${app.home}/Vault";
      volumeMounts = [ homeMount app.ssh.volumeMount ];
      userName = flake.config.me.fullname;
      userEmail = flake.config.me.email;
    };
    env = [
      # BusyBox has no CA bundle; Git and the agents need HTTPS.
      { name = "GIT_SSL_CAINFO"; value = caBundle; }
      { name = "SSL_CERT_FILE"; value = caBundle; }
      # Chromium's own sandbox cannot start under RuntimeDefault seccomp with
      # every capability dropped; this pod is the boundary (see olai's
      # docs/plugins/browsing.md, 'When the container is the sandbox').
      { name = "OLAI_BROWSER_CHROMIUM_SANDBOX"; value = "off"; }
    ];
    # Mount the home before the modules' nested SSH and Git config mounts.
    volumeMounts = lib.mkBefore [
      homeMount
    ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "olai-data"; }
    ];
  };

  services.k3s.manifests.olai.content = [
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
      metadata = { inherit namespace; name = "olai-data"; };
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "local-path";
        resources.requests.storage = "1Gi";
      };
    }

    {
      apiVersion = "apps/v1";
      kind = "Deployment";
      metadata = { inherit namespace; name = "olai"; labels = labels; };
      spec = {
        replicas = 1;
        # Stop the old instance before another opens the same data directory.
        strategy.type = "Recreate";
        selector.matchLabels = labels;
        template = {
          metadata.labels = labels;
          spec = {
            # Stable name reported by olai, independent of Deployment pod suffixes.
            hostname = "olai-k3s";
            inherit (app) automountServiceAccountToken securityContext initContainers volumes;
            containers = [
              {
                name = "olai";
                # A rootfs, nothing more; the program is the mount below.
                inherit image;
                securityContext = app.containerSecurityContext;
                command = inputs.olai.lib.webArgs {
                  package = olai;
                  dataDir = app.git.directory;
                  host = "0.0.0.0";
                  inherit port;
                };
                inherit (app) env volumeMounts;
                ports = [{ name = "http"; containerPort = port; }];
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
        name = "olai";
        labels = labels;
      };
      spec = {
        selector = labels;
        ports = [{ name = "http"; port = 80; targetPort = "http"; }];
      };
    }
  ];
}
