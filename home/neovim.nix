{
  programs.nixvim = {
    enable = true;

    colorschemes.ayu.enable = true;
    options = {
      expandtab = true;
      shiftwidth = 4;
      smartindent = true;
      tabstop = 4;
    };
    globals = {
      mapleader = " ";
    };
    plugins = {
      lightline.enable = true;
      treesitter.enable = true;
      lsp-lines.enable = true;
      illuminate.enable = true;
      lsp = {
        enable = true;
        servers = {
          hls.enable = true;
          marksman.enable = true;
          nil_ls.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
    };
  };
}
