{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  imports = [
    flake.inputs.self.homeModules.default
    flake.inputs.self.homeModules.darwin-only
    "${homeMod}/gui/1password.nix"
    "${homeMod}/cli/controlpersist.nix"
    "${homeMod}/claude-code"

    "${homeMod}/work/juspay.nix"

    "${homeMod}/services/obsidian.nix"
    "${homeMod}/services/kolu.nix"
    "${homeMod}/services/drishti"

    # Remote builders
    "${homeMod}/nix/buildMachines"
    "${homeMod}/nix/buildMachines/pureintent.nix"
  ];

  home.username = "srid";

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
  ];

  services.kolu.host = "100.90.229.113"; # Tailscale IP of zest

  # The pu-managed kolu-ci-* hosts are reachable only from pureintent, so they
  # live in pureintent's drishti (see configurations/nixos/pureintent), not here.
  services.drishti.hosts = [
    "localhost"
    "sincereintent"
    "pureintent"
    "naiveintent"
    "vanjaram.tail12b27.ts.net"
    "nix-infra@rasam.tail12b27.ts.net"
  ];

  home.packages = [
    inputs.disc-scrape.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.zellij-one
    pkgs.twitter-convert
    pkgs.python3
    pkgs.portfwd
  ];
}
