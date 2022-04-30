{ pkgs, inputs, system, ... }:
let
  nvim = inputs.neovim-nightly-overlay.packages.${system}.neovim;
in
{
  imports = [
    ./neovim/coc.nix
    ./neovim/haskell.nix
    ./neovim/zk.nix
  ];
  programs.neovim = {
    enable = true;
    package = nvim;

    extraPackages = [
      pkgs.lazygit
      pkgs.himalaya
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
      (pkgs.vimUtils.buildVimPlugin {
        name = "himalaya";
        src = inputs.himalaya + /vim;
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
        plugin = telescope-file-browser-nvim;
        type = "lua";
        config = ''
          -- You don't need to set any of these options.
          -- IMPORTANT!: this is only a showcase of how you can set default options!
          require("telescope").setup {
            extensions = {
              file_browser = {
                theme = "ivy",
                mappings = {
                  ["i"] = {
                    -- your custom insert mode mappings
                  },
                  ["n"] = {
                    -- your custom normal mode mappings
                  },
                },
              },
            },
          }
          -- To get telescope-file-browser loaded and working with telescope,
          -- you need to call load_extension, somewhere after setup function:
          require("telescope").load_extension "file_browser"
          nmap("<leader>fb", ":Telescope file_browser path=%:p:h<cr>")
          nmap("<leader>fB", ":Telescope file_browser<cr>")
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
          nmap("<leader>b", ":BufferLineCycleNext<cr>")
          nmap("<leader>B", ":BufferLineCyclePrev<cr>")
        '';
      }

      # Developing plugins in Haskell
      nvim-hs-vim

      # Language support
      vim-nix

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
