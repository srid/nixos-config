{ pkgs, flake, ... }:
{
  # Key packages required on nixos and macos
  home.packages = with pkgs; [
    # Unixy tools
    gnumake
    ripgrep
    htop
    nix-output-monitor

    flake.inputs.comma.packages.${pkgs.system}.default
  ];

  programs = {
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;

    # Better terminal, with good rendering.
    kitty = {
      enable = true;
      # Pick "name" from https://github.com/kovidgoyal/kitty-themes/blob/master/themes.json
      theme = "Tokyo Night";
      font = {
        name = "Monaco";
        size = 14;
      };
      keybindings = {
        "kitty_mod+e" = "kitten hints"; # https://sw.kovidgoyal.net/kitty/kittens/hints/
      };
      settings = {
        # https://github.com/kovidgoyal/kitty/issues/371#issuecomment-1095268494
        # mouse_map = "left click ungrabbed no-op";
        # Ctrl+Shift+click to open URL.
      };
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
