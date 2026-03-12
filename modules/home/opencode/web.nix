{ config, lib, pkgs, flake, ... }:

let
  inherit (flake) inputs;
  pathPackages = [
    pkgs.git
    pkgs.gh
    pkgs.nix
    inputs.vira.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.findutils
    pkgs.which
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
