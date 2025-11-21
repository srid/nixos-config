# This machine uses Omarchy
#
# So we consciously pick what we need
{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  imports = [
    "${homeMod}/claude-code"
    "${homeMod}/cli/git.nix"
    "${homeMod}/cli/just.nix"
    "${homeMod}/work/juspay.nix"
    "${homeMod}/cli/direnv.nix"
    "${homeMod}/cli/starship.nix"
    "${homeMod}/cli/bash.nix"
    "${homeMod}/cli/terminal.nix"
    "${homeMod}/gui/1password.nix"
    "${homeMod}/gui/obsidian.nix"

    # Remote builders
    # "${homeMod}/nix/buildMachines"
    # "${homeMod}/nix/buildMachines/sincereintent.nix"
  ];

  home.username = "srid";
  home.stateVersion = "25.05";
}
