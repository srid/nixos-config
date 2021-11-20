{ config, pkgs, ... }:
let
  xmobarPkg = pkgs.callPackage ./xmobar-srid { inherit pkgs; };
in
{
  systemd.user.services.polybar = {
    enable = true;
    description = "Polybar";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polybar}/bin/polybar -c ~/.config/polybar/user example";
      Restart = "on-abnormal";
    };
  };

  environment.systemPackages = [ pkgs.polybar ];

  fonts = {
    fonts = with pkgs; [
      siji
    ];
  };

}
