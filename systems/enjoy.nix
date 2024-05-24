{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    self.nixosModules.default
    "${self}/nixos/disko/trivial.nix"
    "${self}/nixos/nix.nix"
    "${self}/nixos/self/primary-as-admin.nix"
    # "${self}/nixos/server/harden/basics.nix"
  ];

  system.stateVersion = "23.11";
  networking.hostName = "enjoy";
  nixpkgs.hostPlatform = "aarch64-linux";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.openssh.enable = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQRxPoqlThDrkR58pKnJgmeWPY9/wleReRbZ2MOZRyd"
  ];

  hardware.parallels.enable = true;
}
