{ pkgs, ... }:
{
  imports = [
    ./all/zsh.nix
    ./all/bash.nix
    ./all/nushell
    # ./all/emacs.nix
  ];
}
