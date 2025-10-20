{ config, flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@pureintent";
  # nixos-unified.sshTarget = "srid@192.168.2.244";

  imports = [
    self.nixosModules.default
    ./configuration.nix
  ];

  home-manager.sharedModules = [
    # (self + /modules/home/all/dropbox.nix)
    # (self + /modules/home/all/vira.nix)
  ];

  nix.settings.sandbox = "relaxed";

  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  programs.nix-ld.enable = true; # for vscode server

  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
