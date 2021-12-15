{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "ci.ardana.platonic.systems:yByqhxfJ9KIUOyiCe3FYhV7GMysJSA3i5JRvgPuySsI="
    "plutonomicon-pluto.cachix.org-1:ofa/XYzqimDRF96ACKnV7LPiRsz+h4bkHy/a4fbOK04="
  ];
  nix.binaryCaches = [
    "ssh://nix-ssh@ci.ardana.platonic.systems"
    "https://plutonomicon-pluto.cachix.org"
  ];
}
