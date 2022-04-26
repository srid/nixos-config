{ config, pkgs, ... }:

# Based on https://nixos.wiki/wiki/Redshift
{
  services.redshift = {
    enable = true;
  };
}
