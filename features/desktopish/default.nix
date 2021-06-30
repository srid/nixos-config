{ pkgs, ... }: {
  imports = [
    # Isolated features
    ./hidpi.nix
    ./swap-caps-ctrl.nix
    ./light-terminal.nix
    ./screencapture.nix
    ./fonts.nix
    ./touchpad-trackpoint.nix
    ./autolock.nix
    ./redshift.nix

    # WMish things
    ./xmonad
    #./sway.nix
    ./taffybar # Disabled, because it rarely works
  ];

  environment.systemPackages = with pkgs; [
    acpi
    mpv
    pulsemixer
    xorg.xmessage
  ];

  #
  # Various GNOME non-sense that must be enabled to work with WMs
  #

  services.gnome.at-spi2-core.enable = true;

  # https://github.com/taffybar/taffybar/issues/403
  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
  gtk.iconCache.enable = true;

}
