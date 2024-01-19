{ flake, system, ... }:

self: super: {
  fuckport = self.callPackage ./fuckport.nix { };
  nixci = flake.inputs.nixci.packages.${system}.default;
  actual = flake.inputs.actual.packages.${system}.default;
}
