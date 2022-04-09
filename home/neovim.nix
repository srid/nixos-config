{ pkgs, inputs, system, ... }:
let
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
in
{
  programs.neovim = {
    enable = true;
    package = neovim-nightly;
    viAlias = true;
    # withNodeJs = true;

    extraPackages = [
    ];

    plugins = with pkgs.vimPlugins; [
      vim-airline
      papercolor-theme
    ];

    extraConfig = ''
      " papercolor-theme
      " set t_Co=256   " This is may or may not needed.
      set background=light
      colorscheme PaperColor
    '';
  };

}
