# Configuration for my Mac CI VM
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@macci";

  imports = [
    self.darwinModules.default
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "macci";

  # ids.gids.nixbld = 350;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
