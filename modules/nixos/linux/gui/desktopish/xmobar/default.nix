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
      # ExecStart = "${pkgs.xmobar}/bin/xmobar -v -x 2 -f xft:Consolas:size=12 -c '[Run PipeReader \"/etc/nixos/pipe\" \"thepipe\"]' -t \"%%thepipe%%\"";
      Restart = "on-abnormal";
    };
  };

  environment.systemPackages = [ xmobarPkg ];

  # Battery widget requires this.
  services.upower = {
    enable = true;
  };
}
