{ pkgs, ... }: {
  imports = [
    ./iohk.nix
    ./platonic.nix
    ./cm-idris2-pkgs.nix
  ];
}
