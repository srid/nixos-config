{ self, config, ... }:

{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      # Common to all platforms
      common.imports = [
        ./nix.nix
        ./caches
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
        self.nixosModules.home-manager
        self.nixosModules.my-home
        self.nixosModules.common
        ./self-ide.nix
        ./ssh-authorize.nix
        ./current-location.nix
      ];
    };
  };
}
