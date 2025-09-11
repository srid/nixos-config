{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@192.168.2.40";

  imports = [
    self.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen4

    ./configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.tailscale.enable = true;
}
