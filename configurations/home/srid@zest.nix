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
    "${homeMod}/all/1password.nix"
    "${homeMod}/claude-code"
    "${homeMod}/all/juspay.nix"
    "${homeMod}/all/obsidian.nix"

    # Remote builders
    # "${homeMod}/all/buildMachines"
    # "${homeMod}/all/buildMachines/sincereintent.nix"
  ];

  home.username = "srid";

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
  ];
}
