{ self, inputs, config, ... }:
{
  # Configuration common to all macOS systems
  flake = {
    darwinModules = {
      common = self.nixosModules.common;
      home.imports = [
        inputs.home-manager.darwinModules.home-manager
        ({
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "aarch64-darwin";
            flake = { inherit config; };
          };
        })
      ];
      myself = {
        home-manager.users.${config.people.myself} = { pkgs, ... }: {
          imports = [
            self.homeModules.common-darwin
            ../home/shellcommon.nix
            ../home/git.nix
          ];
        };
      };
      default.imports = [
        self.darwinModules.common
        self.darwinModules.home
        self.darwinModules.myself
      ];
    };
    lib-darwin.mkMacosSystem = inputs.darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs system;
        rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
      };
      modules = [
        self.darwinModules.default
        ../systems/darwin.nix
      ];
    };
  };
}
