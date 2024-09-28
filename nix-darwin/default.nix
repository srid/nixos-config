{ self, inputs, config, ... }:
{
  # Configuration common to all macOS systems
  flake = {
    darwinModules = {
      default.imports = [
        {
          home-manager.users.${config.people.myself} = {
            imports = [
              self.homeModules.common-darwin
            ];
          };
        }
        self.nixosModules.common
        inputs.ragenix.darwinModules.default
        inputs.github-nix-ci.darwinModules.default
      ];
    };
  };
}
