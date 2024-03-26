{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    "${self}/nixos/disko/trivial.nix"
    "${self}/nixos/parallels-vm.nix"
    "${self}/nixos/nix.nix"
    "${self}/nixos/self/primary-as-admin.nix"
    "${self}/nixos/server/harden/basics.nix"
    "${self}/clusters/github-runner/nixos-module.nix"
  ];

  system.stateVersion = "23.11";
  networking.hostName = "github-runner";
  nixpkgs.hostPlatform = "aarch64-linux";
  boot = {
    binfmt.emulatedSystems = [ "x86_64-linux" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  services.openssh.enable = true;
}
