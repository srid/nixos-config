{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "admin@infinitude-nixos";

  imports = [
    inputs.agenix.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  services.tailscale.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
