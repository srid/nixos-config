# TODO: WIP
# - [x] Intial config
# - [ ] Colmena deploy, with keys from 1Password.
# - [ ] Github Runners
# - [ ] Distributed builder to host (macOS)
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
    "${self}/nixos/self/primary-as-admin.nix"
    "${self}/nixos/server/harden/basics.nix"
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
  nix.settings.trusted-users = [ "root" "@wheel" ];
  services.openssh.enable = true;
}
