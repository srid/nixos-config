# My Ubuntu VM
{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.linux-only
  ];
  home.username = "srid";
  home.homeDirectory = "/home/srid";
}
