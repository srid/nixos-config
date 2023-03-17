{ pkgs, flake, ... }:
{
  programs.neovim = {
    coc.settings.languageserver.rust = {
      command = "rust-analyzer";
      args = [ ];
      rootPatterns = [
        "Cargo.lock"
      ];
      filetypes = [ "rust" ];
    };

    plugins = with pkgs.vimPlugins; [
      rust-vim
      {
        plugin =
          (pkgs.vimUtils.buildVimPlugin {
            name = "coc-rust-analyzer";
            src = flake.inputs.coc-rust-analyzer;
          });
        type = "lua";
        config = ''
        '';
      }
    ];

  };
}
