{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "public-plutonomicon.cachix.org-1:3AKJMhCLn32gri1drGuaZmFrmnue+KkKrhhubQk/CWc="
  ];
  nix.binaryCaches = [
    "https://public-plutonomicon.cachix.org"
  ];
}
