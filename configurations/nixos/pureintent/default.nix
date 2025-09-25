{ config, flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@pureintent";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/linux/eternal-terminal.nix)
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  home-manager.sharedModules = [
    (self + /modules/home/all/dropbox.nix)
    (self + /modules/home/all/vira.nix)
    {
      services.gotty = {
        enable = true;
        port = 9999;
        command = "${lib.getExe config.programs.tmux.package} new-session -A -s gotty";
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
  ];

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
