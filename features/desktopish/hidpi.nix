{ config, pkgs, ... }:
{
  services.xserver.dpi = 192;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
        Xft.dpi: 192
        Xcursor.theme: Adwaita
        Xcursor.size: 64
    EOF
  '';
}
