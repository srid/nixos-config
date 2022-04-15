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
      # vim-airline
      # lualine-nvim
      feline-nvim

      # For working mouse support when running inside tmux
      terminus

      lazygit-nvim

      # Preferred theme
      nvim-treesitter
      aurora

      telescope-nvim
      telescope-zoxide

      # Buffer tabs
      bufferline-nvim

      nvim-hs-vim

      # Language support
      vim-nix
      haskell-vim
    ];

    extraConfig = ''
      set nobackup
      set termguicolors " 24-bit colors
      colorscheme aurora
      " Use spave instead of \ as leader key, like doom-emacs
      map <Space> <Leader>

      " telescope
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      
      " luiline
      lua << END
      require('feline').setup()
      END

      " bufferline
      lua << EOF
      require("bufferline").setup{}
      EOF
      nnoremap <silent>[b :BufferLineCycleNext<CR>
      nnoremap <silent>b] :BufferLineCyclePrev<CR>
      nnoremap <silent>be :BufferLineSortByExtension<CR>
      nnoremap <silent>bd :BufferLineSortByDirectory<CR>
    '';
  };

}
