{ pkgs, lib, ... }:

# Tools already available in standard GitHub Runners; so we provide
# them here:
with pkgs; [
  coreutils
  which
  jq
  # https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml#L40
  (runCommandNoCC "gtar" { } ''
    mkdir -p $out/bin
    ln -s ${lib.getExe gnutar} $out/bin/gtar
  '')
]
