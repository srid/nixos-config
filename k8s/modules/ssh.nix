# Enable ssh.enable to mount SSH credentials in the app's home.
# The app supplies the Secret and trusted host keys.
{ config, lib, pkgs, name, ... }:
let
  cfg = config.ssh;
  prefix = "${name}-ssh";
  inherit (lib) mkOption types;
in
{
  options.ssh = {
    enable = lib.mkEnableOption "SSH credentials in the app's home";
    # Existing Secret containing id_ed25519 and id_ed25519.pub.
    secretName = mkOption { type = types.str; default = prefix; };
    # Strict host checking rejects destinations absent from this list.
    knownHosts = mkOption { type = types.lines; default = ""; };
  };

  config = lib.mkIf cfg.enable {
    packages = [ pkgs.openssh ];
    manifests = [{
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = { inherit (config) namespace; name = "${prefix}-config"; };
      data = {
        passwd = "root:x:0:0:root:/root:/bin/sh\n${config.user.name}:x:${toString config.user.uid}:${toString config.user.gid}::${config.home}:/bin/sh\n";
        config = ''
          Host *
            IdentitiesOnly yes
            StrictHostKeyChecking yes
            UpdateHostKeys no
        '';
        known_hosts = cfg.knownHosts;
      };
    }];
    # Copy root-owned Secret files to tmpfs as the app user, before Git starts.
    initContainers = lib.mkBefore [{
      name = "${prefix}-keys";
      inherit (config) image;
      securityContext = config.containerSecurityContext;
      command = [
        "/bin/sh"
        "-ec"
        ''
          umask 077
          mkdir -p /ssh/home
          chmod 700 /ssh/home
          cp /keys/id_ed25519 /keys/id_ed25519.pub /ssh/home/
          cp /ssh-config/config /ssh-config/known_hosts /ssh/home/
          chmod 600 /ssh/home/id_ed25519
          chmod 644 /ssh/home/id_ed25519.pub /ssh/home/config /ssh/home/known_hosts
        ''
      ];
      volumeMounts = [
        { name = "${prefix}-secret"; mountPath = "/keys"; readOnly = true; }
        { name = "${prefix}-config"; mountPath = "/ssh-config"; readOnly = true; }
        { name = "${prefix}-home"; mountPath = "/ssh"; }
      ];
    }];
    volumeMounts = [
      { name = "${prefix}-home"; mountPath = "${config.home}/.ssh"; subPath = "home"; readOnly = true; }
      { name = "${prefix}-config"; mountPath = "/etc/passwd"; subPath = "passwd"; readOnly = true; }
    ];
    volumes = [
      { name = "${prefix}-home"; emptyDir.medium = "Memory"; }
      { name = "${prefix}-config"; configMap.name = "${prefix}-config"; }
      {
        name = "${prefix}-secret";
        secret = {
          inherit (cfg) secretName;
          defaultMode = 288; # 0440: readable through the pod's fsGroup.
        };
      }
    ];
  };
}
