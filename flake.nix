{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, home-manager, nixpkgs }: 
    let 
      # Make configuration for any computer I use in my home office.
      mkHomeMachine = configurationNix: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # System configuration
          configurationNix
          ./modules/passwordstore.nix
          ./modules/protonmail-bridge.nix
          ./modules/monitor-brightness.nix

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.srid = import ./home.nix;
          }
        ];
      };
    in {
      nixosConfigurations.p71 = mkHomeMachine ./p71/configuration.nix;
      nixosConfigurations.x1c7 = mkHomeMachine ./x1c7/configuration.nix;
    };
}
