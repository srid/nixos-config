{ config, pkgs, ... }:
{
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.useXkbConfig = true;
}
