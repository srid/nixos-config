{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  imports = [
    flake.inputs.self.homeModules.default
    flake.inputs.self.homeModules.darwin-only
    "${homeMod}/gui/1password.nix"

    "${homeMod}/work/juspay.nix"
    "${homeMod}/gui/obsidian.nix"

    # Remote builders
    # "${homeMod}/nix/buildMachines"
    # "${homeMod}/nix/buildMachines/sincereintent.nix"
  ];

  home.username = "srid";

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
  ];
}
