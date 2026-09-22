{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@gossamer";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/linux/gc.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
  ];

  zramSwap.enable = true;
}
