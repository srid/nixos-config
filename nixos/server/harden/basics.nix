{ flake, ... }: {

  # Firewall
  networking.firewall.enable = true;

  # Enable auditd
  security.auditd.enable = true;
  security.audit.enable = true;

  # Make me a sudoer without password
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.${flake.config.people.myself} = {
    extraGroups = [ "wheel" ];
  };

  # Standard openssh protections
  #
  # Which goes with the password-less sudo above for the ssh-authorized user.
  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = false;
      allowSFTP = false;
    };
  };

  # 🤲
  nix.settings.allowed-users = [ "root" "@users" ];
}
