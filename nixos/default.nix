{ self, inputs, config, ... }:

{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      # NixOS modules that are known to work on nix-darwin.
      # Thsi is shared with nix-darwin/default.nix
      common.imports = [
        ./nix.nix
        ./caches
        ./self/primary-as-admin.nix
      ];

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
        ./self/self-ide.nix
        ./current-location.nix
      ];
    };
  };
}
