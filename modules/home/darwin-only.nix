{ lib, ... }:
{
  imports = [
    ./cli/zsh.nix
    ./cli/bash.nix
  ];

  # macOS defaults to 256 FDs; Nix tarball-cache walks every file in a
  # github: flake input and aborts on large trees (olai, kolu).
  programs.zsh.initContent = lib.mkAfter ''
    if (( $(ulimit -n) < 10240 )); then
      ulimit -n 65536 2>/dev/null || ulimit -n 10240
    fi
  '';
  programs.bash.initExtra = lib.mkAfter ''
    if [ "$(ulimit -n)" -lt 10240 ]; then
      ulimit -n 65536 2>/dev/null || ulimit -n 10240
    fi
  '';
}
