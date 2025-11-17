# This machine uses Omarchy
#
# So we consciously pick what we need
{ flake, pkgs, lib, ... }:
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
    "${homeMod}/all/juspay.nix"
    "${homeMod}/all/direnv.nix"
    "${homeMod}/all/starship.nix"
    "${homeMod}/all/bash.nix"
    "${homeMod}/all/terminal.nix"
    "${homeMod}/all/juspay-vertex.nix"
    "${homeMod}/all/1password.nix"

    # Remote builders
    # "${homeMod}/all/buildMachines"
    # "${homeMod}/all/buildMachines/sincereintent.nix"
  ];

  home.username = "srid";
  home.stateVersion = "25.05";
}
