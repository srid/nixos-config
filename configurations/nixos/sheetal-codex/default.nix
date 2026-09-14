# Dev container on naiveintent. SSH over the tailnet
# (`ssh srid@sheetal-codex`).
#
# Lifecycle (`just incus <cmd> sheetal-codex`):
# modules/nixos/linux/incus/README.md.
{ flake, lib, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = flake.config.me.username;
in
{
  imports = [
    (self + /modules/nixos/linux/incus/guest.nix)
  ];

  networking.hostName = "sheetal-codex";
  nixpkgs = {
    hostPlatform = "x86_64-linux"; # runs on naiveintent
    config.allowUnfree = true;
    # homeModules.default (terminal.nix) needs overlay packages (`ci`, …).
    overlays = lib.attrValues self.overlays;
  };

  nix.settings.trusted-users = lib.mkForce [ "root" username ];

  # Dynamically-linked CLIs (Codex, VS Code server, …) need the standard
  # ELF loader path.
  programs.nix-ld.enable = true;
  services.openssh.enable = true;
  # lxc-instance-common defaults this to socket activation.
  services.openssh.startWhenNeeded = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = true;
    openssh.authorizedKeys.keys = [
      flake.config.me.sshKey
      # pureintent srid
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnWriRB3c/G+O4/N5ALnOQBdBTp9LeGC6HNYTZCCGS2 srid@pureintent"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${username} = {
    imports = [
      self.homeModules.default
      self.homeModules.linux-only
    ];
    home.packages = with pkgs; [
      uv
      python3
      nodejs
    ];
  };

  system.stateVersion = "25.11";
}
