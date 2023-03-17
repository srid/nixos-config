{ pkgs, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
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


    ];
  };
}
