{ self, inputs, config, ... }:

{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      # NixOS modules that are known to work on nix-darwin.
      common.imports = [
        ./nix.nix
        ./caches
        ./self/primary-as-admin.nix
      ];

      my-home = {
        users.users.${config.people.myself}.isNormalUser = true;
        home-manager.users.${config.people.myself} = {
          imports = [
            self.homeModules.common-linux
          ];
        };
      };

      default.imports = [
        self.nixosModules.my-home
        self.nixosModules.common
        inputs.ragenix.nixosModules.default
        inputs.github-nix-ci.nixosModules.default
        ./self/self-ide.nix
        ./current-location.nix
      ];
    };
  };
}
