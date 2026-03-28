{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.darwin-only
    (self + /modules/home/nix/gc.nix)
  ];

  home.username = "srid";
}
