{ self, inputs, config, ... }:

{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      # NixOS modules that are known to work on nix-darwin.
      # Thsi is shared with nix-darwin/default.nix
      common = ./common;

      default.imports = [
        {
          users.users.${config.people.myself}.isNormalUser = true;
          home-manager.users.${config.people.myself} = {
            imports = [
              self.homeModules.common-linux
            ];
          };
        }
        self.nixosModules.common
        inputs.ragenix.nixosModules.default
        inputs.github-nix-ci.nixosModules.default
        ./self-ide.nix
        ./current-location.nix
      ];
    };
  };
}
