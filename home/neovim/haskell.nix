{ pkgs, ... }:
{
  programs.neovim = {
    coc.settings.languageserver.haskell = {
      command = "haskell-language-server-wrapper";
      args = [ "--lsp" ];
      rootPatterns = [
        "*.cabal"
        "cabal.project"
        "hie.yaml"
      ];
      filetypes = [ "haskell" "lhaskell" ];
    };

    plugins = with pkgs.vimPlugins; [
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
    ];

  };
}
