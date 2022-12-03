{ self, inputs, config, ... }:
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      other-people = {
        # Temporarily sharing with Uday.
        users.users.uday.isNormalUser = true;
        home-manager.users."uday" = {
          imports = [
            self.homeModules.common-linux
            ../home/git.nix
          ];
        };
      };
      myself = {
        home-manager.users.${config.people.myself} = { pkgs, ... }: {
          imports = [
            self.homeModules.common-linux
            ../home/shellcommon.nix
            ../home/git.nix
          ];
        };
      };
      default.imports = [
        self.nixosModules.home-manager
        self.nixosModules.myself
        ./caches
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
      ] ++ extraModules;
    };
  };
}
