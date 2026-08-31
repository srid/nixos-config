# Configuration common to all Linux systems
{ flake, ... }:

let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      # isNormalUser comes from shared/primary-as-admin.nix.
      home-manager.useGlobalPkgs = true;
      home-manager.backupFileExtension = "hm-backup";
      home-manager.users.${config.me.username} = { };
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.linux-only
      ];
    }
    self.nixosModules.common
    inputs.agenix.nixosModules.default # Used in github-runner.nix & hedgedoc.nix
    ./linux/current-location.nix
  ];

  boot.loader.grub.configurationLimit = 5; # Who needs more?
}
