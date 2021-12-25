{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "cm-idris2-pkgs.cachix.org-1:YB2oJSEsD5oMJjAESxolC2GQtE6B5I6jkWhte2gtXjk="
  ];
  nix.binaryCaches = [
    "https://cm-idris2-pkgs.cachix.org"
  ];
}
