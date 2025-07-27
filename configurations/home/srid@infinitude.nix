{ pkgs, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.darwin-only
  ];

  home.username = "srid";

  home.packages = with pkgs; [
  ];
}
