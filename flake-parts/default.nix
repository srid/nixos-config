# An opinionated module that creates flake outputs based on a known directory structure.
#
# cf. Convention over configuration
{ inputs, self, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{

  flake = {
    darwinConfigurations = inputs.nixpkgs.lib.mapAttrs'
      (fn: _:
        let
          inherit (inputs.nixpkgs) lib;
          hostname = lib.removeSuffix ".nix" fn;
        in
        lib.nameValuePair hostname (self.nixos-flake.lib.mkMacosSystem
          { home-manager = true; }
          "${self}/configurations/darwin/${fn}")
      )
      (builtins.readDir "${self}/configurations/darwin");

    nixosConfigurations = inputs.nixpkgs.lib.mapAttrs'
      (fn: _:
        let
          inherit (inputs.nixpkgs) lib;
          hostname = lib.removeSuffix ".nix" fn;
        in
        lib.nameValuePair hostname (self.nixos-flake.lib.mkLinuxSystem
          { home-manager = true; }
          "${self}/configurations/nixos/${fn}")
      )
      (builtins.readDir "${self}/configurations/nixos");
  };
}
