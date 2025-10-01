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
    (self + /modules/nixos/linux/nix-cache-server-cf)
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

  # Cache key: cache.srid.ca:EGydqsWFaTZeW6vsXnOHclTXrmJ58gq/bkVYhRpuzQ8=
  services.nix-cache-server-cf = {
    enable = true;
    secretKeyPath = "nix-cache-server-cf/cache-key.pem";
    cloudflare = {
      tunnelId = "55569b77-5482-47c7-bf25-53d93b64d0c8";
      credentialsPath = "nix-cache-server-cf/cloudflared-credentials.json";
      domain = "cache.srid.ca";
    };
  };


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
