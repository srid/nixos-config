{ pkgs, inputs, system, ... }:
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${system}.neovim;

    extraPackages = [
    ];

    # Full list here,
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
    plugins = with pkgs.vimPlugins; [
      # Status bar for vim
      vim-airline

      # Preferred theme
      papercolor-theme

      telescope-nvim
      telescope-zoxide

      nvim-hs-vim

      # Language support
      vim-nix
      haskell-vim
    ];

    extraConfig = ''
      set nobackup

      " Use spave instead of \ as leader key, like doom-emacs
      map <Space> <Leader>

      " papercolor-theme
      " set t_Co=256   " This is may or may not needed.
      set background=dark
      colorscheme PaperColor

      " telescope
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    '';
  };

}
