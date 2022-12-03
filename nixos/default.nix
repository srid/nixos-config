{ self, inputs, config, ... }:
let
  mkHomeModule = name: extraModules: {
    users.users.${name}.isNormalUser = true;
    home-manager.users.${name} = {
      imports = [
        self.homeModules.common-linux
        ../home/git.nix
      ] ++ extraModules;
    };
  };
in
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      guests.imports = [
        # Temporarily sharing with Uday, until he gets better machine.
        (mkHomeModule "uday" [ ])
      ];
      myself = mkHomeModule "srid" [
        ../home/shellcommon.nix
      ];
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
