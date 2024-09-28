{ self, inputs, config, ... }:
{
  # Configuration common to all macOS systems
  flake = {
    darwinModules = {
      default.imports = [
        {
          home-manager.users.${config.people.myself} = { };
          home-manager.sharedModules = [
            self.homeModules.default
            self.homeModules.darwin-only
          ];
        }
        self.nixosModules.common
        inputs.ragenix.darwinModules.default
      ];
    };
  };
}
