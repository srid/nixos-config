# Platform-independent terminal setup
{ flake, ... }:

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
    };
    nix-index-database.comma.enable = true;
  };
}
