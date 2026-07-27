{ pkgs, ... }:
{
  programs.neovim = {
    plugins = [
      pkgs.vimPlugins.lean-nvim
    ];

    initLua = ''
      require("lean").setup {
        mappings = true,
      }
    '';
  };
}
