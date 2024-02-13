{ flake, ... }: {

  # Firewall
  networking.firewall.enable = true;

  security.sudo.execWheelOnly = true;

  security.sudo.wheelNeedsPassword = false;
  users.users.${flake.config.people.myself} = {
    extraGroups = [ "wheel" ];
  };

  security.auditd.enable = true;
  security.audit.enable = true;

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = false;
      allowSFTP = false;
    };
    fail2ban = {
      enable = true;
      ignoreIP = [
        "100.80.93.92" # Tailscale "appreciate"
      ];
    };
  };
  nix.settings.allowed-users = [ "root" "@users" ];
}
