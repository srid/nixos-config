{ self, inputs, config, ... }:
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      # These imports are platform independent.
      common.imports = [
        ./caches
      ];
      home.imports = [
        inputs.home-manager.nixosModules.home-manager
        ({
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
          };
        })
      ];
      default.imports =
        self.nixosModules.common.imports ++
        self.nixosModules.home.imports ++
        [
          ./self-ide.nix
          ./takemessh
          ./current-location.nix
        ];
    };

    lib.mkLinuxSystem = extraModules: inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      # Arguments to pass to all modules.
      specialArgs = { inherit system inputs; };
      modules = [
        self.nixosModules.default
        {
          home-manager.users.${config.myUserName} = { pkgs, ... }: {
            imports = [
              self.homeModules.common-linux
              ../home/shellcommon.nix
              (import ../home/git.nix {
                userName = "Sridhar Ratnakumar";
                userEmail = "srid@srid.ca";
              })
            ];
          };
        }
      ] ++ extraModules;
    };
  };
}
