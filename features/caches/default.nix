{ pkgs, ... }: {
  imports = [
    ./iohk.nix
    ./reflex.nix
    # ./platonic.nix -- don't need ssh cache
    ./cm-idris2-pkgs.nix
  ];
}
