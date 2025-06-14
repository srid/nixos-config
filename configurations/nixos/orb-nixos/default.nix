{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@orb";

  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    self.nixosModules.default
    ./configuration.nix
  ];
}
