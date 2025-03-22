{ pkgs, ... }:
{
  imports = [
    ./all/zsh.nix
    ./all/nushell.nix
    # ./all/emacs.nix
  ];

  home.packages = with pkgs; [
    maccy
  ];
}
