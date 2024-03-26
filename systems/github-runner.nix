# TODO: WIP
# - [x] Intial config
# - [ ] Colmena deploy, with keys from 1Password.
# - [ ] Github Runners
# - [ ] Distributed builder to host (macOS)
{ flake, pkgs, ... }:

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

  # Runners
  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups.github-runner = { };
  nix.settings.trusted-users = [ "github-runner" ];
  services.github-runners = {
    perpetuum = {
      enable = true;
      replace = true;
      tokenFile = "/run/keys/github-runner-token.secret";
      extraPackages = with pkgs; [
        coreutils
        nixci
      ];
      user = "github-runner";
      group = "github-runner";
      url = "https://github.com/srid/perpetuum";
      name = "perpetuum-1";
    };
  };
}
