# Configuration for my M1 Macbook Max as headless server
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@naivete";

  imports = [
    self.darwinModules.default
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "naivete";

  services.tailscale.enable = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
