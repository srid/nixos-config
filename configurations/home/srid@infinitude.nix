{ lib, pkgs, flake, ... }:
{
  imports = [
    flake.inputs.self.homeModules.default
    flake.inputs.self.homeModules.darwin-only
    (flake.inputs.self + /modules/home/all/1password.nix)
    (flake.inputs.self + /modules/home/all/juspay-vertex.nix)
  ];

  home.username = "srid";
  home.packages = [
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.tart
  ];
}
