{ pkgs, flake, ... }:

{
  # Key packages required on nixos and macos
  home.packages = with pkgs; [
    # Unixy tools
    gnumake
    ripgrep
    htop
    nix-output-monitor

    # Open zellij for current project.
    (pkgs.nuenv.mkScript {
      name = "zux";
      script = ''
        let PRJ = (zoxide query -i)
        let NAME = ($PRJ | parse $"($env.HOME)/{relPath}" | get relPath | first | str replace -a / ／)
        echo $"Launching zellij for ($PRJ)"
        cd $PRJ ; exec zellij attach -c $NAME
      '';
    })

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
      settings = {
        theme = if pkgs.system == "aarch64-darwin" then "dracula" else "default";
        # https://github.com/nix-community/home-manager/issues/3854
        themes.dracula = {
          fg = [ 248 248 242 ];
          bg = [ 40 42 54 ];
          black = [ 0 0 0 ];
          red = [ 255 85 85 ];
          green = [ 80 250 123 ];
          yellow = [ 241 250 140 ];
          blue = [ 98 114 164 ];
          magenta = [ 255 121 198 ];
          cyan = [ 139 233 253 ];
          white = [ 255 255 255 ];
          orange = [ 255 184 108 ];
        };
      };
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
        # https://github.com/kovidgoyal/kitty/issues/847
        macos_option_as_alt = "yes";
      };
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
