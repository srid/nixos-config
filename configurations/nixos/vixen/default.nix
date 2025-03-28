{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen4
    (self + /modules/nixos/linux/gui/_1password.nix)
    (self + /modules/nixos/linux/gui/steam.nix)
    (self + /modules/nixos/linux/gui/desktopish/monitor-brightness.nix)

    ./configuration.nix
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    google-chrome
    zed-editor
    calibre
  ];
}
