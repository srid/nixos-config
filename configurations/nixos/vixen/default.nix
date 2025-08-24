{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen4

    ./configuration.nix
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.tailscale.enable = true;
}
