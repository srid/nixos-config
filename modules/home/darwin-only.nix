{ pkgs, ... }:
{
  imports = [
    ./all/zsh.nix
    ./all/nushell
    # ./all/emacs.nix
  ];
}
