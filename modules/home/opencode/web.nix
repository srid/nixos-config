{ config, lib, pkgs, ... }:

let
  pathPackages = [
    pkgs.git
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.findutils
  ];
in
{
  programs.opencode.web = {
    enable = true;
    # Bind to Tailscale IP only
    extraArgs = [ "--hostname" "100.122.32.106" "--port" "4096" ];
  };
  systemd.user.services.opencode-web.Service = {
    Environment = [ "PATH=${lib.makeBinPath pathPackages}" ];
  };
}
