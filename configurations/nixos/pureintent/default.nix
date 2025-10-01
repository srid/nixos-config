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
    inputs.nix-serve-cloudflared.nixosModules.default
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
  age.secrets."nix-serve-cloudflared/cache-key.pem" = {
    file = self + /secrets/nix-serve-cloudflared/cache-key.pem.age;
    mode = "0400";
  };

  age.secrets."nix-serve-cloudflared/cloudflared-credentials.json" = {
    file = self + /secrets/nix-serve-cloudflared/cloudflared-credentials.json.age;
    mode = "0400";
  };

  services.nix-serve-cloudflared = {
    enable = true;
    secretKeyFile = config.age.secrets."nix-serve-cloudflared/cache-key.pem".path;
    cloudflare = {
      tunnelId = "55569b77-5482-47c7-bf25-53d93b64d0c8";
      credentialsFile = config.age.secrets."nix-serve-cloudflared/cloudflared-credentials.json".path;
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

  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
