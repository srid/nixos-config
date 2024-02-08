{
  programs.nixvim = {
    enable = true;

    colorschemes.one.enable = true;
    plugins = {
      lightline.enable = true;
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
