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
    "${homeMod}/cli/atuin.nix"
    "${homeMod}/claude-code"

    "${homeMod}/work/juspay.nix"
    "${homeMod}/work/opencode.nix"

    "${homeMod}/services/obsidian.nix"
    "${homeMod}/services/drishti"

    # Remote builders
    "${homeMod}/nix/buildMachines"
    "${homeMod}/nix/buildMachines/pureintent.nix"
  ];

  home.username = "srid";

  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
  ];

  # The pu-managed kolu-ci-* hosts are reachable only from pureintent, so they
  # live in pureintent's drishti (see configurations/nixos/pureintent), not here.
  services.drishti.hosts = [
    "localhost"
    "petit"
    "pureintent"
    "naiveintent"
  ];

  home.packages = [
    inputs.disc-scrape.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.twitter-convert
    pkgs.python3
    pkgs.uv
    pkgs.portfwd
    # The kolu terminal-side CLIs, without running the kolu service itself.
    inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.kaval-tui
    inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.padi-tui
    # olai CLI only — the web service lives on myolai / naiveintent.
    inputs.olai.packages.${pkgs.stdenv.hostPlatform.system}.olai
  ];
}
