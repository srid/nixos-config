{ pkgs, ... }:

{
  services.hardware.bolt.enable = true;
  environment.systemPackages = [ pkgs.asdbctl ];
  services.udev.packages = [ pkgs.asdbctl ];
}
