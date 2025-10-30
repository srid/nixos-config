{ config, flake, pkgs, lib, ... }:

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
  ];

  users.users.${flake.config.me.username}.linger = true;
  home-manager.sharedModules = [
    "${homeMod}/all/vira.nix"
    # (self + /modules/home/all/dropbox.nix)

    # Remote builders
    "${homeMod}/all/buildMachines"
    "${homeMod}/all/buildMachines/sincereintent.nix"
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

  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
    5001
  ];

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
