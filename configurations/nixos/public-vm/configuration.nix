{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/lxd-virtual-machine.nix"
    (self + /modules/nixos/shared/primary-as-admin.nix)
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Tailscale to connect to the VM from anywhere
  services.tailscale.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
  system.stateVersion = "24.11";
}
