{ self, inputs, ... }:
{
  # Configuration common to all macOS systems
  flake = {
    darwinModules = {
      common = self.nixosConfig.common;
      home.imports = [
        inputs.home-manager.darwinModules.home-manager
        ({
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "aarch64-darwin";
          };
        })
      ];
      default.imports =
        self.darwinModules.common ++
        self.darwinModules.home.imports;
    };
    mkMacosSystem = userName: inputs.darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs system;
        rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
      };
      modules = [
        self.darwinModules.default
        ../systems/darwin.nix
        {
          home-manager.users.${userName} = { pkgs, ... }: {
            imports = [
              self.homeModules.common-darwin
              ../home/shellcommon.nix
              (import ../home/git.nix {
                userName = "Sridhar Ratnakumar";
                userEmail = "srid@srid.ca";
              })
            ];
            programs.zsh.initExtra = ''
              export PATH=/etc/profiles/per-user/${userName}/bin:/run/current-system/sw/bin/:$PATH
            '';
          };
        }
      ];
    };
  };
}
