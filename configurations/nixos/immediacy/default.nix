{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@192.168.2.43"; # Not using Tailscale host yet (broken right now)

  imports = [
    self.nixosModules.default
    ./configuration.nix
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.syncthing = { enable = true; user = "srid"; dataDir = "/home/srid/Documents"; };

  programs.nix-ld.enable = true; # for vscode server

  environment.systemPackages = with pkgs; [
  ];

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
