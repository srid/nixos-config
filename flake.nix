{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, home-manager, nixpkgs }: {
    nixosConfigurations.x1c7 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # System configuration
        ./configuration.nix
        ./modules/passwordstore.nix
        ./modules/protonmail-bridge.nix

        # home-manager configuration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.srid = import ./home.nix;
        }
      ];
    };
  };
}
