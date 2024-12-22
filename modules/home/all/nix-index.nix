# Platform-independent terminal setup
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];

  programs = {
    # Command not found handler based on nixpkgs
    nix-index-fork = {
      enable = true;
      enableZshIntegration = true;
      enableNixCommand = true;
      database = inputs.nix-index-database.packages.${pkgs.system}.nix-index-small-database;
    };
    command-not-found.enable = false;
    # nix-index-database.comma.enable = true;
  };
}
