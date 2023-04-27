{ self, config, ... }:

{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      myself = {
        users.users.${config.people.myself}.isNormalUser = true;
        home-manager.users.${config.people.myself} = {
          imports = [
            self.homeModules.common-linux
          ];
        };
      };

      # Common to all platforms
      common.imports = [
        ./nix.nix
        ./caches
      ];

      default.imports = [
        self.nixosModules.home-manager
        self.nixosModules.myself
        self.nixosModules.common
        ./self-ide.nix
        ./ssh-authorize.nix
        ./current-location.nix
      ];
    };
  };
}
