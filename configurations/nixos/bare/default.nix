# Minimal Incus container on naiveintent. SSH over the tailnet
# (`ssh srid@bare`).
#
# Lifecycle (`just incus <cmd> bare`):
# modules/nixos/linux/incus/README.md.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = flake.config.me.username;
in
{
  imports = [
    (self + /modules/nixos/linux/incus/guest.nix)
  ];

  networking.hostName = "bare";
  nixpkgs.hostPlatform = "x86_64-linux"; # runs on naiveintent

  services.openssh.enable = true;
  # lxc-instance-common defaults this to socket activation.
  services.openssh.startWhenNeeded = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      flake.config.me.sshKey
      # pureintent srid
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnWriRB3c/G+O4/N5ALnOQBdBTp9LeGC6HNYTZCCGS2 srid@pureintent"
    ];
  };

  system.stateVersion = "25.11";
}
