{ lib, pkgs, flake, ... }:
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

  home.packages = [
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.tart
  ];
}
