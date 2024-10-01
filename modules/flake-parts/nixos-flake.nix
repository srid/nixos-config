{ inputs, ... }:
{
  imports = [
    inputs.nixos-flake.flakeModules.default
    inputs.nixos-flake.flakeModules.autoWire
  ];
  perSystem = { self', ... }: {
    packages.default = self'.packages.activate;

    # Flake inputs we want to update periodically
    # Run: `nix run .#update`.
    nixos-flake = {
      primary-inputs = [
        "nixpkgs"
        "home-manager"
        "nix-darwin"
        "nixos-flake"
        "nix-index-database"
        "nixvim"
        "omnix"
      ];
    };
  };
}
