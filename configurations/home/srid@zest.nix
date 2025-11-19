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
    (flake.inputs.self + /modules/home/all/1password.nix)
    (flake.inputs.self + /modules/home/all/juspay-vertex.nix)
    (flake.inputs.self + /modules/home/claude-code)
    "${homeMod}/all/juspay.nix"

    # Remote builders
    # "${homeMod}/all/buildMachines"
    # "${homeMod}/all/buildMachines/sincereintent.nix"
  ];

  home.username = "srid";
}
