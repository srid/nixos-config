# https://github.com/claymager/idris2-pkgs
{ pkgs, ... }: {
  nix.settings.trusted-public-keys = [
    "cm-idris2-pkgs.cachix.org-1:YB2oJSEsD5oMJjAESxolC2GQtE6B5I6jkWhte2gtXjk="
    "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
  ];
  nix.settings.substituters = [
    "https://cm-idris2-pkgs.cachix.org"
    "https://srid.cachix.org"
  ];
}
