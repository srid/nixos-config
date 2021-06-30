{ pkgs, ... }: {
  #
  # Various GNOME non-sense that must be enabled to work with WMs
  #

  services.gnome.at-spi2-core.enable = true;

  # https://github.com/taffybar/taffybar/issues/403
  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/issues/43836#issuecomment-419217138
    hicolor-icon-theme
    gnome-icon-theme
  ];


}
