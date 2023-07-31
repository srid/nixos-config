{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # NOTE: disabled, because causes breakage often
    /* config.global = {
      strict_env = true;
    }; */
  };
}
