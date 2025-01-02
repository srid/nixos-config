{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      gtk-titlebar = false; # better on tiling wm
      font-size = 10;
      theme = "catppuccin-mocha";
    };
  };
}
