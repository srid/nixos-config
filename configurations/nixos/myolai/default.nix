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
{ config, flake, pkgs, ... }:

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

  # Claude Code's native installer (claude.ai/install.sh) downloads a
  # dynamically-linked binary; give it the standard ELF loader path.
  programs.nix-ld.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    # dropbox and olai are home-manager user services; they must start
    # at boot without a login session.
    linger = true;
  };

  # Activation refuses to clobber files it didn't create (lazygit writes a
  # default ~/.config/lazygit/config.yml on first run); move them aside.
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${username} = {
    imports = [
      # Dropbox disabled for now; olai runs against a local (unsynced)
      # dataDir until this comes back.
      # (self + /modules/home/services/dropbox.nix)
      # git + delta + lazygit, configured as on the other hosts.
      (self + /modules/home/cli/git.nix)
      (self + /modules/home/cli/just.nix)
      (self + /modules/home/editors/neovim)
      ./olai.nix
    ];
    home.packages = [ pkgs.uv ];
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
