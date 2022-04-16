{ pkgs, inputs, system, ... }:
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${system}.neovim;

    coc = {
      enable = true;
      settings = {
        languageserver = {
          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "cabal.project"
              "hie.yaml"
            ];
            filetypes = [ "haskell" "lhaskell" ];
          };
        };
      };
    };

    extraPackages = [
      pkgs.lazygit
    ];

    # Full list here,
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
    plugins = with pkgs.vimPlugins; [
      # Status bar for vim

      # For working mouse support when running inside tmux
      terminus

      lazygit-nvim

      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      # Preferred theme
      tokyonight-nvim
      sonokai
      dracula-vim
      gruvbox
      papercolor-theme
      (pkgs.vimUtils.buildVimPlugin {
        name = "eldar";
        src = inputs.vim-eldar;
      })

      # Doom-emacs like experience
      { 
        plugin = vim-which-key;
        type = "lua";
        # TODO: How to port this to Lua?
        config = ''
          vim.cmd([[
          map <Space> <Leader>
          let g:mapleader = "\<Space>"
          let g:maplocalleader = ','
          nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
          nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
          ]])
          '';
      }
      # TODO: Don't know how to configure this correctly
      # nvim-whichkey-setup-lua

      { 
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          nmap("<leader>ff", ":Telescope find_files<cr>")
          nmap("<leader>fg", ":Telescope live_grep<cr>")
          nmap("<leader>fb", ":Telescope buffers<cr>")
          nmap("<leader>fh", ":Telescope help_tags<cr>")
          '';
      }
      { 
        plugin = telescope-zoxide;
        type = "lua";
        config = ''
          nmap("<leader>fz", ":Telescope zoxide list<cr>")
          '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
            options = {
              theme = 'tokyonight'
            }
          }
          '';
      }

      # Buffer tabs
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = ''
          require("bufferline").setup{ }
          nmap("[b", ":BufferLineCycleNext<cr>")
          nmap("b]", ":BufferLineCyclePrev<cr>")
          nmap("be", ":BufferLineSortByExtension<cr>")
          nmap("bd", ":BufferLineSortByDirectory<cr>")
          '';
      }

      # Developing plugins in Haskell
      nvim-hs-vim

      # Language support
      vim-nix
      { 
        plugin = haskell-vim;
        type = "lua";
        config = ''
          vim.cmd([[
          let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
          let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
          let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
          let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
          let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
          let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
          ]])
          '';
      }
      vim-markdown
    ];

    # Add library code here for use in the Lua config from the
    # plugins list above.
    extraConfig = ''
      lua << EOF
      ${builtins.readFile ./neovim.lua}
      EOF
    '';
  };

}
