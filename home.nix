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

  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

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

    doom-emacs = {
      enable = true;
      doomPrivateDir = ./config/doom.d;
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
        })  # This doesn't render colors well
        onedark-vim

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
        "Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
        "If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
        "(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
        if (empty($TMUX))
          if (has("nvim"))
            "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
            let $NVIM_TUI_ENABLE_TRUE_COLOR=1
          endif
          "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
          "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
          " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
          if (has("termguicolors"))
            set termguicolors
          endif
        endif

        " papercolor-theme
        " set t_Co=256   " This is may or may not needed.
        " set background=light
        " let g:tokyonight_style = "day"
        syntax on
        colorscheme onedark

        " Find files using Telescope command-line sugar.
        nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
        nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
        nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
        nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

        " IDE
        lua require'lspconfig'.hls.setup{}

        "Markdown
        let g:vim_markdown_new_list_item_indent = 2

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
