{ self, inputs, config, ... }:
{
  # Configuration common to all macOS systems
  flake = {
    darwinModules = {
      my-home = {
        home-manager.users.${config.people.myself} = {
          imports = [
            self.homeModules.common-darwin
          ];
        };
      };

      default.imports = [
        self.darwinModules.my-home
        self.nixosModules.common
        inputs.ragenix.darwinModules.default
        inputs.github-nix-ci.darwinModules.default
      ];
    };
  };
}
