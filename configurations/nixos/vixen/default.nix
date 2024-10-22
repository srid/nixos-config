# Hetzner dedicated: AX41-NVMe
{ flake, ... }:

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

  services.openssh.enable = true;
  services.tailscale.enable = true;

  programs.nix-ld.enable = true; # for vscode server
}
