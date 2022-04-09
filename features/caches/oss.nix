{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "cm-idris2-pkgs.cachix.org-1:YB2oJSEsD5oMJjAESxolC2GQtE6B5I6jkWhte2gtXjk="
    "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.binaryCaches = [
    "https://cm-idris2-pkgs.cachix.org"
    "https://srid.cachix.org"
    "nix-community.cachix.org"
  ];
}
