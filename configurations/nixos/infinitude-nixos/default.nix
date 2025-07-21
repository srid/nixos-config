{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@192.168.64.6";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
