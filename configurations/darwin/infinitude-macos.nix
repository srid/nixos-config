# Configuration for my Mac CI VM
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "admin@infinitude-macos";

  imports = [
    inputs.agenix.darwinModules.default
    # (self + /modules/nixos/shared/github-runner.nix)
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "infinitude-macos";

  ids.gids.nixbld = 350;

  services.tailscale.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
