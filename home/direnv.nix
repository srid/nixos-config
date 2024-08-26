{ config, ... }:
{
  programs.direnv = {
    enable = true;
    package = config.nix.package;
    nix-direnv.enable = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
