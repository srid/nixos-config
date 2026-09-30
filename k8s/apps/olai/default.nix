# Learning example: browser → Tailscale proxy → Service → Deployment, with a PVC
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
in
{
  imports = [ ../../modules ];

  k8s.apps.olai = {
    inherit namespace image;
    home = "/data";
    packages = [ agents.claude agents.codex ];
    ssh = {
      enable = true;
      secretName = "olai-ssh";
      knownHosts = (import ../../known-hosts.nix).github;
    };
    git = {
      enable = true;
      url = "git@github.com:srid/Vault.git";
      directory = "${app.home}/Vault";
      userName = flake.config.me.fullname;
      userEmail = flake.config.me.email;
    };
    env = [
      # BusyBox has no CA bundle; Git and the agents need HTTPS.
      { name = "GIT_SSL_CAINFO"; value = caBundle; }
      { name = "SSL_CERT_FILE"; value = caBundle; }
    ];
    # Mount the home before the modules' nested SSH and Git config mounts.
    volumeMounts = lib.mkBefore [
      { name = "data"; mountPath = app.home; }
      { name = "nix-store"; mountPath = "/nix/store"; readOnly = true; }
    ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "olai-data"; }
      { name = "nix-store"; hostPath = { path = "/nix/store"; type = "Directory"; }; }
    ];
  };

  # GitHub repo deploy key for srid/Vault, the olai vault repository.
  age.secrets."olai-ssh.yaml".file = inputs.self + /secrets/olai-ssh.yaml.age;
  services.k3s.manifests.olai-ssh.source = config.age.secrets."olai-ssh.yaml".path;

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
            inherit (app) securityContext initContainers volumes;
            containers = [
              {
                name = "olai";
                # A rootfs, nothing more; the program is the mount below.
                inherit image;
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
        # The operator creates a tailnet device: browse http://olai-k3s.
        annotations = {
          "tailscale.com/expose" = "true";
          "tailscale.com/hostname" = "olai-k3s";
        };
      };
      spec = {
        selector = labels;
        ports = [{ name = "http"; port = 80; targetPort = "http"; }];
      };
    }
  ];
}
