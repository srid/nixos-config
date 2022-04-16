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
      lualine-nvim

      # For working mouse support when running inside tmux
      terminus

      lazygit-nvim

      # Preferred theme
      nvim-treesitter
      tokyonight-nvim

      # Doom-emacs like experience
      telescope-nvim
      telescope-zoxide
      vim-which-key
      # TODO: Don't know how to configure this correctly
      # nvim-whichkey-setup-lua

      # Buffer tabs
      bufferline-nvim

      # Developing plugins in Haskell
      nvim-hs-vim

      # Language support
      vim-nix
      haskell-vim
      vim-markdown
    ];

    # Note: Lua based config is in ./neovim.lua
    extraConfig = ''
      " which-key
      " TODO: How to port this to Lua?
      map <Space> <Leader>
      let g:mapleader = "\<Space>"
      let g:maplocalleader = ','
      nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
      nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

      lua << EOF
      ${builtins.readFile ./neovim.lua}
      EOF
    '';
  };

}
