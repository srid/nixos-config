{ pkgs, flake, ... }: {

  # Firewall
  networking.firewall.enable = true;

  security.sudo.execWheelOnly = true;

  security.auditd.enable = true;
  security.audit.enable = true;

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password"; # distributed-build.nix requires it
      settings.PasswordAuthentication = false;
      allowSFTP = false;
    };
    fail2ban = {
      enable = true;
      ignoreIP = [
      ];
    };
  };
  nix.settings.allowed-users = [ "root" "@users" ];
  nix.settings.trusted-users = [ "root" flake.config.people.myself ];
}
