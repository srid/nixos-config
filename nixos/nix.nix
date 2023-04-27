{ flake, pkgs, lib, ... }:

{
  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnsupportedSystem = true;
      allowUnfree = true;
    };
    overlays = [
      flake.inputs.nuenv.overlays.nuenv
      (self: super: { devour-flake = self.callPackage flake.inputs.devour-flake { }; })
    ];
  };

  nix = {
    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry.nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    settings.experimental-features = "nix-command flakes repl-flake";
    # I don't have an Intel mac.
    settings.extra-platforms = lib.mkIf pkgs.stdenv.isDarwin "aarch64-darwin x86_64-darwin";
  };
}

