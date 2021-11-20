{ config, pkgs, lib, ... }:
{
  hardware.video.hidpi.enable = true;
  services.xserver.dpi = 170;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
        Xft.dpi: 192
        Xcursor.theme: Adwaita
        Xcursor.size: 64
    EOF
  '';
}
