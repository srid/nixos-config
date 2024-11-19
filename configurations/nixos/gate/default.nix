{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "gate";

  imports = [
    ./configuration.nix
    (self + /modules/nixos/shared/primary-as-admin.nix)
    (self + /webapps/proxy.nix)
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  services.openssh.settings.PasswordAuthentication = false;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
