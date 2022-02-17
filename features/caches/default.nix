{ pkgs, ... }: {
  imports = [
    ./iohk.nix
    # ./reflex.nix -- not working on reflex*
    # ./platonic.nix -- don't need ssh cache
    ./cm-idris2-pkgs.nix
  ];
}
