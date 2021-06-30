# Since the xmonad config will be built by nixos-rebuild, we use the
# nix-channel's nixpkgs.
{ pkgs ? import <nixpkgs> { } }:
let
  inherit (import ./dep/gitignoresrc { inherit (pkgs) lib; }) gitignoreSource;
in
pkgs.haskellPackages.developPackage {
  name = "taffybar-srid";
  root = gitignoreSource ./.;
  modifier = drv:
    pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages;
    [
      cabal-install
      cabal-fmt
      ghcid
      haskell-language-server
    ]);
  overrides = self: super: with pkgs.haskell.lib; { };
}
