{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "ci.ardana.platonic.systems:yByqhxfJ9KIUOyiCe3FYhV7GMysJSA3i5JRvgPuySsI="
    "public-plutonomicon.cachix.org-1:3AKJMhCLn32gri1drGuaZmFrmnue+KkKrhhubQk/CWc="
  ];
  nix.binaryCaches = [
    "ssh://nix-ssh@ci.ardana.platonic.systems"
    "https://public-plutonomicon.cachix.org"
  ];
}
