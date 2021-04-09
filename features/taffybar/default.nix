{ config, pkgs, ... }:
let
  taffyPkg = pkgs.callPackage ./taffybar-srid { inherit pkgs; };
in
{
  systemd.user.services.taffybar = {
    enable = true;
    description = "Taffybar";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${taffyPkg}/bin/taffybar-srid";
      Restart = "on-abnormal";
    };
  };

  # Battery widget requires this.
  services.upower = {
    enable = true;
  };
}
