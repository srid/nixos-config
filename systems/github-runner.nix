# TODO: WIP
# - [x] Intial config
# - [x] Colmena deploy, with keys from 1Password.
# - [x] Github Runners
# - [ ] Distributed builder to host (macOS)
# - [ ] Refactor, to allow multiple repos (then remove easy-github-runners.nix)
{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  user = "github-runner";
  group = "github-runner";
  tokenFile = "/run/keys/github-runner-token.secret"; # See colmena keys in top-level flake.nix
  # Convenient function to create multiple runners per single personal repo.
  mkPersonalRunners = user:
    lib.concatMapAttrs (repoName: meta:
      lib.listToAttrs (lib.flip builtins.map (lib.range 1 meta.num) (idx:
        let
          name = "perpetuum-${builtins.toString idx}";
        in
        lib.nameValuePair name {
          inherit user group tokenFile name;
          enable = true;
          replace = true;
          extraPackages = with pkgs; [
            coreutils
            nixci
          ];
          url = "https://github.com/${user}/${repoName}";
        })));
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
  users.users.${user} = {
    inherit group;
    isSystemUser = true;
  };
  users.groups.${group} = { };
  nix.settings.trusted-users = [ user ];
  services.github-runners = mkPersonalRunners "srid" {
    perpetuum.num = 2;
  };
}
