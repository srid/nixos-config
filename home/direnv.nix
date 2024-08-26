{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      # Until https://github.com/juspay/nix-dev-home/issues/68
      package = lib.mkIf (config.nix.package != null)
        (pkgs.nix-direnv.override { nix = config.nix.package; });
    };
    config.global = {
      hide_env_diff = true;
    };
  };
}
