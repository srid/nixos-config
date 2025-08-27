{ pkgs, ... }:
{
  imports = [
    ./all/zsh.nix
    ./all/nushell
    # ./all/emacs.nix
  ];

  home.packages = [
    pkgs.tart
  ];
}
