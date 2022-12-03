{ self, inputs, ... }:
{
  # Configuration common to all Linux systems
  flake.nixosModules = {
    # These imports are platform independent.
    common.imports = [
      ./caches
    ];
    home.imports = [
      inputs.home-manager.nixosModules.home-manager
      ({
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
          system = "x86_64-linux";
        };
      })
    ];
    default.imports =
      self.nixosModules.common.imports ++
      self.nixosModules.home.imports ++
      [
        ./self-ide.nix
        ./takemessh
        ./current-location.nix
      ];
  };
}
