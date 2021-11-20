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

  # https://github.com/taffybar/taffybar/issues/403
  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/issues/43836#issuecomment-419217138
    hicolor-icon-theme
    gnome-icon-theme
  ];
}
