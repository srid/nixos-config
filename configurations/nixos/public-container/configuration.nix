{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
    (self + /modules/nixos/shared/primary-as-admin.nix)
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.firewall.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
  system.stateVersion = "24.11";
}
