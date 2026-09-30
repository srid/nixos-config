# Learning example: browser → Ingress → Service → Deployment, with a PVC
# preserving data across pod restarts. This single-node setup runs olai from
# the host Nix store; BusyBox supplies the container root filesystem.
{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  olai = inputs.olai.packages.${pkgs.stdenv.hostPlatform.system}.olai;

  namespace = "olai-k3s";
  hostname = "olai-k3s.test";
  port = 7714; # olai's own production port, per the home-manager module
  labels = { app = "olai"; };
in
{
  services.k3s.manifests.olai.content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = { name = namespace; };
    }

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
            securityContext = {
              runAsNonRoot = true;
              runAsUser = 1000;
              runAsGroup = 1000;
              fsGroup = 1000;
            };
            containers = [
              {
                name = "olai";
                # A rootfs, nothing more; the program is the mount below.
                image = "busybox:1.36.1@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662";
                command = [
                  "${olai}/bin/olai"
                  "web"
                  "/data"
                  "--port"
                  (toString port)
                  "--host"
                  "0.0.0.0"
                ];
                env = [ { name = "HOME"; value = "/data"; } ];
                ports = [ { name = "http"; containerPort = port; } ];
                volumeMounts = [
                  { name = "data"; mountPath = "/data"; }
                  {
                    name = "nix-store";
                    mountPath = "/nix/store";
                    readOnly = true;
                  }
                ];
              }
            ];
            volumes = [
              { name = "data"; persistentVolumeClaim.claimName = "olai-data"; }
              { name = "nix-store"; hostPath = { path = "/nix/store"; type = "Directory"; }; }
            ];
          };
        };
      };
    }

    {
      apiVersion = "v1";
      kind = "Service";
      metadata = { inherit namespace; name = "olai"; labels = labels; };
      spec = {
        selector = labels;
        ports = [ { name = "http"; port = 80; targetPort = "http"; } ];
      };
    }

    # No authentication: reachable by anyone who can reach Traefik.
    {
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = { inherit namespace; name = "olai"; };
      spec = {
        ingressClassName = "traefik";
        rules = [
          {
            host = hostname;
            http.paths = [
              {
                path = "/";
                pathType = "Prefix";
                backend.service = { name = "olai"; port.number = 80; };
              }
            ];
          }
        ];
      };
    }
  ];

  # So a browser on this machine reaches the Ingress by name; Traefik is on 80.
  networking.hosts."127.0.0.1" = [ hostname ];
}
