{ pkgs, inputs, system, ... }:
{
  imports = [
    (inputs.smos + "/nix/home-manager-module.nix")
  ];
  programs.smos.enable = true;
}
