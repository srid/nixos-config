# My Ubuntu VM
{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.common-linux
  ];
  home.username = "srid";
  home.homeDirectory = "/home/srid";
}
