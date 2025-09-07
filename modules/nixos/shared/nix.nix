{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnsupportedSystem = true;
      allowUnfree = true;
    };
    overlays = lib.attrValues self.overlays;
  };

  nix = {
    # Choose from https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=nix
    # package = pkgs.nixVersions.latest;

    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry = {
      nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    };

    settings = {
      max-jobs = "auto";
      experimental-features = "nix-command flakes";
      # I don't have an Intel mac.
      extra-platforms = lib.mkIf pkgs.stdenv.isDarwin "aarch64-darwin x86_64-darwin";
      # Nullify the registry for purity.
      flake-registry = pkgs.writeText "empty-flake-registry.json" ''{"flakes":[],"version":2}'';
      trusted-users = [ "root" (if pkgs.stdenv.isDarwin then flake.config.me.username else "@wheel") ];
    };
  };
}
