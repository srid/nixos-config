# Dropbox + olai in an incus container on naiveintent. The outliner is
# reachable only at https://myolai.<tailnet>.ts.net — olai binds
# loopback and `tailscale serve` is the only way in.
#
# Lifecycle (`just incus <cmd> myolai`): modules/nixos/linux/incus/README.md.
# One-time Dropbox account link after the first deploy: the daemon logs a
# https://www.dropbox.com/cli_link_nonce=… URL — from `just incus shell
# myolai`, grab it with
#   journalctl _SYSTEMD_USER_UNIT=dropbox.service | grep dropbox.com
# and open it in a browser.
{ config, flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = flake.config.me.username;
in
{
  imports = [
    (self + /modules/nixos/linux/incus/guest.nix)
  ];

  networking.hostName = "myolai";
  nixpkgs.hostPlatform = "x86_64-linux"; # runs on naiveintent
  nixpkgs.config.allowUnfree = true; # dropbox

  # Publish olai's (loopback-bound) port on the tailnet.
  incus.servePort = config.home-manager.users.${username}.services.olai.port;

  users.users.${username} = {
    isNormalUser = true;
    # dropbox and olai are home-manager user services; they must start
    # at boot without a login session.
    linger = true;
  };

  home-manager.users.${username} = {
    imports = [
      (self + /modules/home/services/dropbox.nix)
      (self + /modules/home/services/olai.nix)
    ];
    services.olai.host = "127.0.0.1";
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
