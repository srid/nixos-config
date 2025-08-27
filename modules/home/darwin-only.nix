{ pkgs, ... }:
{
  imports = [
    ./all/zsh.nix
    ./all/bash.nix
    ./all/nushell
    # ./all/emacs.nix
  ];

  home.packages = [
    pkgs.tart
  ];
}
