{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem = { self', ... }: {
    packages.default = self'.packages.activate;

    # Flake inputs we want to update periodically
    # Run: `nix run .#update`.
    nixos-unified = {
      primary-inputs = [
        "nixpkgs"
        "home-manager"
        "nix-darwin"
        # "nixos-hardware"
        "nix-index-database"
        "nixvim"
        "nix-ai-tools"
        "AI"
      ];
    };
  };
}
