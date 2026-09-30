# Host cache access for apps: an untrusted daemon and read-only store mounts.
# Enable with k8s.apps.<name>.nix.enable; only cached packages can be fetched.
{ config, lib, pkgs, ... }:
let
  socketDirectory = "/run/k8s-nix";
in
{
  # Separate daemon access from the host user's trusted socket.
  config = lib.mkIf (lib.any (app: app.nix.enable) (lib.attrValues config.k8s.apps)) {
    # An empty group prevents builds even if clients override max-jobs.
    users.groups.k8s-nix-no-builders = { };
    systemd.services.k8s-nix-daemon = {
      description = "Untrusted, downloads-only Nix access for Kubernetes apps";
      wantedBy = [ "multi-user.target" ];
      before = [ "k3s.service" ];
      environment.NIX_DAEMON_SOCKET_PATH = "${socketDirectory}/socket";
      serviceConfig = {
        ExecStart = "${pkgs.nix}/bin/nix daemon --extra-experimental-features daemon-trust-override --force-untrusted --option build-users-group k8s-nix-no-builders --option builders '' --option sandbox true";
        RuntimeDirectory = "k8s-nix";
        RuntimeDirectoryPreserve = "yes";
        Restart = "on-failure";
      };
    };
    systemd.services.k3s = {
      wants = [ "k8s-nix-daemon.service" ];
      after = [ "k8s-nix-daemon.service" ];
    };
  };

  # Extend the app schema here so both sides of Nix access stay together.
  options.k8s.apps = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ config, name, ... }: {
      options.nix.enable = lib.mkEnableOption "Nix CLI using the host's package cache";

      config = lib.mkIf config.nix.enable {
        packages = [ pkgs.nix pkgs.bashInteractive pkgs.cacert ];
        env = [
          { name = "NIX_REMOTE"; value = "unix://${socketDirectory}/socket"; }
          { name = "NIX_CONFIG"; value = "experimental-features = nix-command flakes\nmax-jobs = 0\n"; }
          { name = "NIX_SSL_CERT_FILE"; value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; }
          { name = "SHELL"; value = "${pkgs.bashInteractive}/bin/bash"; }
          { name = "USER"; value = config.user.name; }
        ];
        volumeMounts = [
          { name = "${name}-nix-store"; mountPath = "/nix/store"; readOnly = true; }
          { name = "${name}-nix-socket"; mountPath = socketDirectory; readOnly = true; }
        ];
        volumes = [
          { name = "${name}-nix-store"; hostPath = { path = "/nix/store"; type = "Directory"; }; }
          { name = "${name}-nix-socket"; hostPath = { path = socketDirectory; type = "Directory"; }; }
        ];
      };
    }));
  };
}
