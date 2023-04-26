{ flake, ... }:

{
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    flake.inputs.nuenv.overlays.nuenv
    (self: super: { devour-flake = self.callPackage flake.inputs.devour-flake { }; })
  ];

  nix = {
    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry.nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    settings.extra-platforms = "aarch64-darwin x86_64-darwin";
    settings.experimental-features = "nix-command flakes repl-flake";
  };
}

