{ pkgs, ... }: {

  networking.firewall.enable = true;
  security.sudo.execWheelOnly = true;
  security.auditd.enable = true;
  security.audit.enable = true;
  services = {
    openssh = {
      enable = true;
      permitRootLogin = "prohibit-password"; # distributed-build.nix requires it
      passwordAuthentication = false;
      allowSFTP = false;
    };
    fail2ban = {
      enable = true;
      ignoreIP = [
        # quebec
        "70.53.187.43"
      ];
    };
  };
}
