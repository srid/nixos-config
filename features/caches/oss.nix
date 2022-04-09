{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.binaryCaches = [
    "https://srid.cachix.org"
    "nix-community.cachix.org"
  ];
}
