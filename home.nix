{ config, pkgs, ... }:

let 
  nix-thunk = 
    (import (builtins.fetchTarball "https://github.com/obsidiansystems/nix-thunk/archive/master.tar.gz") {}).command;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "srid";
  home.homeDirectory = "/home/srid";

  home.packages = with pkgs; [
    cachix
    # tig
    # dotnet-sdk_5
    # nix-thunk
  ];

  programs = {
    git = {
      # package = pkgs.gitAndTools.gitFull;
      enable = true;
      userName = "Sridhar Ratnakumar";
      userEmail = "srid@srid.ca";
      aliases = {
        co = "checkout";
        ci = "commit";
        cia = "commit --amend";
        s = "status";
        st = "status";
        b = "branch";
        p = "pull --rebase";
        pu = "push";
      };
      ignores = [ "*~" "*.swp" ];
      extraConfig = {
        init.defaultBranch = "master";
        #core.editor = "nvim";
        #protocol.keybase.allow = "always";
        credential.helper = "store --file ~/.git-credentials";
        pull.rebase = "false";
      };
    };

    tmux = {
      enable = true;
      shortcut = "a";
      aggressiveResize = true;
      baseIndex = 1;
      newSession = true;
      # Stop tmux+escape craziness.
      escapeTime = 0;
      # Force tmux to use /tmp for sockets (WSL2 compat)
      secureSocket = false;

      extraConfig = ''
        # Mouse works as expected
        set-option -g mouse on
        # easy-to-remember split pane commands
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # withNodeJs = true;

      plugins = with pkgs.vimPlugins; [
        vim-nix
      ];
    };

    bash = {
      enable = true;
      shellAliases = {
        g = "git";
        t = "tig";
        l = "ls --color=always";
      };
    };

    starship = {
      enable = true;
    };

    bat.enable = true;
    autojump.enable = true;
    fzf.enable = true;
    jq.enable = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
