{ pkgs, ... }: {
  #
  # Various GNOME non-sense that must be enabled to work with WMs
  #

  services.gnome.at-spi2-core.enable = true;

  # https://unix.stackexchange.com/a/434752
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # keyring GUI
  # This shit messes up 5k monitor merge
  # services.xserver.displayManager.gdm.enable = true;

  # https://github.com/taffybar/taffybar/issues/403
  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/issues/43836#issuecomment-419217138
    hicolor-icon-theme
    gnome-icon-theme
  ];

}
