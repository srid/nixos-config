{
  description = "Srid's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    himalaya.url = "github:srid/himalaya/nixify-crate2nix";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Make configuration for any computer I use in my home office.
      mkHomeMachine = configurationNix: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # System configuration
          configurationNix
          ./features/passwordstore.nix
          ./features/syncthing.nix
          ./features/virtualization.nix
          ./features/email
          ./features/monitor-brightness.nix

          # HACK: This should really go under ./features/email
          ({
            environment.systemPackages = [ inputs.himalaya.outputs.defaultPackage.${system} ];
          })

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.srid = import ./home.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations.p71 = mkHomeMachine ./hosts/p71.nix;
      nixosConfigurations.x1c7 = mkHomeMachine ./hosts/x1c7.nix;
    };
}
