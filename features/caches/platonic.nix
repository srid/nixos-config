{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "ci.ardana.platonic.systems:yByqhxfJ9KIUOyiCe3FYhV7GMysJSA3i5JRvgPuySsI="
  ];
  nix.binaryCaches = [
    "ssh://nix-ssh@ci.ardana.platonic.systems"
  ];
}
