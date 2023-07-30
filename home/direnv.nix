{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global = {
      strict_env = true;
    };
  };
}
