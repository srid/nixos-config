{ pkgs, ... }: {
  programs.gnupg = {
    # Enabling the agent requires a system restart.
    agent = {
      enable = true;
      enableExtraSocket = true;
      pinentryFlavor = "curses";
    };
  };
  environment.systemPackages = with pkgs; [
    pass
    # Pinentry doesn't work on WSL NixOS unless manually configured on gpg-agent.conf
    # See https://sigkill.dk/writings/guides/nixos_pass.html
    pinentry-curses
  ];
}
