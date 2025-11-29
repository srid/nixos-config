{ pkgs, ... }:
{
  # npm global packages
  # https://nixos.wiki/wiki/Node.js#Using_npm_install_-g_fails
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  home.packages = with pkgs; [
    nodejs
  ];
}
