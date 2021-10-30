{ config, pkgs, ... }:

{
  services.tlp = {
    settings = {
      # https://wiki.archlinux.org/title/Wake-on-LAN#Enable_WoL_in_TLP
      WOL_DISABLE = "N";
    };
  };

  environment.systemPackages = with pkgs; [
    ethtool
  ];
}
