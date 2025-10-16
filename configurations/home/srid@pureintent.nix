{ flake, pkgs, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  imports = [
    "${homeMod}/claude-code"
    "${homeMod}/all/git.nix"
    "${homeMod}/all/just.nix"
    "${homeMod}/all/direnv.nix"
    "${homeMod}/all/starship.nix"
    "${homeMod}/all/bash.nix"
    "${homeMod}/all/terminal.nix"
    "${homeMod}/all/gotty.nix"
    "${homeMod}/all/juspay-vertex.nix"
    # "${homeMod}/all/1password.nix"
    (self + /modules/home/all/vira.nix)
  ];

  home.username = "srid";
  home.stateVersion = "25.05";

  services.gotty = {
    enable = true;
    port = 9999;
    command = "${lib.getExe config.programs.tmux.package} new-session -A -s gotty";
    write = true;
  };


}
