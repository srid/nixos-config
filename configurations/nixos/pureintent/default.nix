{ config, flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@pureintent";
  # nixos-unified.sshTarget = "srid@192.168.2.244";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/linux/beszel.nix)
  ];

  users.users.${flake.config.me.username}.linger = true;
  home-manager.sharedModules = [
    "${homeMod}/work/juspay.nix"
    "${homeMod}/services/vira.nix"

    "${homeMod}/services/dropbox.nix"
    "${homeMod}/services/obsidian.nix"

    # Remote builders
    "${homeMod}/nix/buildMachines"
    "${homeMod}/nix/buildMachines/sincereintent.nix"
    {
      services.ttyd = {
        enable = true;
        port = 9999;
        command = "${lib.getExe config.programs.tmux.package} new-session -A -s ttyd";
        write = true;
      };
    }
  ];

  nix.settings.sandbox = "relaxed";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB in megabytes
  }];

  services.glances = {
    enable = true;
    openFirewall = true;
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
