{ pkgs, ... }:
{
  # Key packages required on nixos and macos
  home.packages = with pkgs; [
    # Unixy tools
    gnumake
    ripgrep
    htop
    nix-output-monitor

    # Open tmux for current project.
    (pkgs.writeShellApplication {
      name = "pux";
      runtimeInputs = [ pkgs.tmux ];
      text = ''
        PRJ="''$(zoxide query -i)"
        echo "Launching tmux for ''$PRJ"
        set -x
        cd "''$PRJ" && \
          exec tmux -S "''$PRJ".tmux attach
      '';
    })
  ];

  programs = {
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;

    zellij = {
      enable = true;
    };

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
        confirm_os_window_close = "0";
      };
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
