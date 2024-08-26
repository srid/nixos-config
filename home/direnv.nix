{ config, lib, ... }:
{
  programs.direnv = {
    enable = true;
    package = lib.mkIf (config.nix.package != null) config.nix.package;
    nix-direnv.enable = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
