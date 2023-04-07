{ flake, ... }:

{
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ flake.inputs.nuenv.overlays.nuenv ];
}

