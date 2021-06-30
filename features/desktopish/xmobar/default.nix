{ config, pkgs, ... }:
let
  xmobarPkg = pkgs.callPackage ./xmobar-srid { inherit pkgs; };
in
{
  systemd.user.services.xmobar = {
    enable = true;
    description = "Xmobar";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${xmobarPkg}/bin/xmobar-srid";
      Restart = "on-abnormal";
    };
  };

  # Battery widget requires this.
  services.upower = {
    enable = true;
  };
}
