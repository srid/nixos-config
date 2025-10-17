{ pkgs, ... }:
{
  nix = {
    package = pkgs.nix;
    enable = true;
    distributedBuilds = true;
  };
}
