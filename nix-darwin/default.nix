{ self, inputs, ... }:
{
  # Configuration common to all macOS systems
  flake.darwinModules = {
    common = self.nixosConfig.common;
    home.imports = [
      inputs.home-manager.darwinModules.home-manager
      ({
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
          system = "aarch64-darwin";
        };
      })
    ];
    default.imports =
      self.darwinModules.common ++
      self.darwinModules.home.imports;
  };
}
