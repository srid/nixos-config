{ flake, pkgs, ... }:

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
    ./dell-xps-16.nix
    ./tailscale.nix
    (self + /modules/nixos/linux/gc.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
    "${homeMod}/services/kolu.nix"
    {
      # Include loopback: the local hostname resolves to 127.0.0.2.
      # Remote access is allowed only via tailscale0 in tailscale.nix.
      services.kolu.host = "0.0.0.0";
    }
  ];

  environment.systemPackages = [
    inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  zramSwap.enable = true;
}
