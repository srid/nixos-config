{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      gtk-titlebar = false; # better on tiling wm
      font-size = 10;
      theme = "catppuccin-mocha";

      # Default window split keybindings (no custom config needed):
      # Cmd+D (macOS) / Ctrl+Shift+D (Linux) - Split right
      # Cmd+Shift+D (macOS) / Ctrl+Shift+Shift+D (Linux) - Split down  
      # Cmd+W (macOS) / Ctrl+Shift+W (Linux) - Close current split
      # Cmd+[ / Cmd+] (macOS) / Ctrl+Shift+[ / Ctrl+Shift+] (Linux) - Navigate splits
    };
  };
}
