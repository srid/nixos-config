{ pkgs, inputs, system, ... }:
let
  nix-thunk =
    (import (builtins.fetchTarball "https://github.com/obsidiansystems/nix-thunk/archive/master.tar.gz") { }).command;
  himalayaSrc = inputs.himalaya;
  himalaya = import ./features/email/himalaya.nix { inherit pkgs inputs system; };
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "srid";
  home.homeDirectory = "/home/srid";

  home.packages = with pkgs; [
    cachix
    tig
    gh
    procs # no more: ps -ef | grep 
    tealdeer
    # ^ easy to forget these; write SRS?
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
      package = neovim-nightly;
      viAlias = true;
      # withNodeJs = true;

      extraPackages = [
        himalaya
      ];

      plugins = with pkgs.vimPlugins; [
        # Language support
        vim-nix
        vim-markdown

        # IDE support
        completion-nvim # A async completion framework aims to provide completion to neovim's built in LSP written in Lua
        lsp-status-nvim
        nvim-treesitter  # syntax highlighting
        nvim-lspconfig

        # Theme
        (pkgs.vimUtils.buildVimPlugin {
          name = "tokyonight.nvim";
          src = inputs.tokyonight;
        })

        # TODO: comment
        vim-airline
        # papercolor-theme
        fzf-vim
        ale
        telescope-nvim

        (pkgs.vimUtils.buildVimPlugin {
          name = "himalaya";
          src = himalayaSrc + "/vim";
        })
      ];

      extraConfig = ''
        " papercolor-theme
        " set t_Co=256   " This is may or may not needed.
        " set background=light
        let g:tokyonight_style = "day"
        colorscheme tokyonight

        " Find files using Telescope command-line sugar.
        nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
        nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
        nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
        nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

        " IDE
        lua require'lspconfig'.hls.setup{}
      '';
    };


    bash = {
      enable = true;
      shellAliases = {
        g = "git";
        t = "tig";
        l = "ls --color=always";
        h = "himalaya";
      };
      sessionVariables = { };
    };

    starship = {
      enable = true;
    };

    bat.enable = true;
    autojump.enable = true;
    fzf.enable = true;
    jq.enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "p71" = {
        hostname = "192.168.2.25";
      };
    };
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
