# Configuration for my M1 Macbook Max as headless server
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@infinitude";

  imports = [
    self.darwinModules.default
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "infinitude";

  # Using GUI app; so disable this.
  # services.tailscale.enable = true;

  environment.systemPackages = [ pkgs.tart ];

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  ids.gids.nixbld = 350;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
