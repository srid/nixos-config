{ pkgs, ... }: {
  imports = [
    ./iohk.nix
    ./reflex.nix
    ./platonic.nix
    ./cm-idris2-pkgs.nix
  ];
}
