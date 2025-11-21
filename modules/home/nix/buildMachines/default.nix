{ pkgs, lib, ... }:
{
  nix = {
    package = lib.mkDefault pkgs.nix;
    enable = true;
    distributedBuilds = true;
    extraOptions = ''
      # Let remote builders download from cache directly.
      # This is to avoid download-cum-copy on main builder.
      builders-use-substitutes = true
    '';
  };
}
