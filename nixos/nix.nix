{ flake, ... }:

{
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    flake.inputs.nuenv.overlays.nuenv
    (self: super: { devour-flake = self.callPackage flake.inputs.devour-flake { }; })
  ];
}

