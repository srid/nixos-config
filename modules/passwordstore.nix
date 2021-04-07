{ pkgs, ... }: {
  programs.gnupg = {
    # Enabling the agent requires a system restart.
    agent = {
      enable = true;
      enableExtraSocket = true;
      # pinentryFlavor = "curses";
    };
  };
  environment.systemPackages = with pkgs; [
    pass
  ];
}
