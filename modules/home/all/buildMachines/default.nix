{ pkgs, lib, ... }:
{
  nix = {
    package = lib.mkDefault pkgs.nix;
    enable = true;
    distributedBuilds = true;
  };
}
