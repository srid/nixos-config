{
  description = "Srid's NixOS / nix-darwin configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Principle inputs (kept minimal to speed up nix develop/run/shell)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-unified.url = "github:srid/nixos-unified";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs = {
      darwin.follows = "nix-darwin";
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };

    # Everything else is managed by npins (see ./npins/)
  };

  outputs = flakeInputs@{ self, ... }:
    let
      sources = import ./npins;

      # Lazily evaluate a flake from npins source using flake-compat.
      # The flake is only fetched/evaluated when its outputs are actually used,
      # so `nix develop` and `nix run` stay fast.
      callFlake = src: (import sources.flake-compat { inherit src; }).defaultNix;

      # Wrap a source path to behave like a `flake = false` input
      # (supports both string interpolation and .outPath access)
      wrapSource = src: { outPath = src; };

      # Build an inputs-like attrset from npins sources.
      # Modules continue to use `inputs.foo` / `flake.inputs.foo` unchanged.
      npinsInputs = {
        # Source-only inputs (formerly flake = false)
        nixos-vscode-server = wrapSource sources.nixos-vscode-server;
        skills = wrapSource sources.skills;
        git-hooks = wrapSource sources.git-hooks;
        jumphost-nix = wrapSource sources.jumphost-nix;

        # Flake inputs (lazily evaluated via flake-compat)
        disko = callFlake sources.disko;
        disc-scrape = callFlake sources.disc-scrape;
        emanote = callFlake sources.emanote;
        github-nix-ci = callFlake sources.github-nix-ci;
        imako = callFlake sources.imako;
        kolu = callFlake sources.kolu;
        landrun-nix = callFlake sources.landrun-nix;
        nix-agent-wire = callFlake sources.nix-agent-wire;
        nix-index-database = callFlake sources.nix-index-database;
        nixos-hardware = callFlake sources.nixos-hardware;
        nixvim = callFlake sources.nixvim;
        oc = callFlake sources.oc;
        vira = callFlake sources.vira;
      };

      inputs = flakeInputs // npinsInputs;
    in
    flakeInputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      imports = (with builtins;
        map
          (fn: ./modules/flake-parts/${fn})
          (attrNames (readDir ./modules/flake-parts)));

      perSystem = { lib, system, ... }: {
        # Make our overlay available to the devShell
        # "Flake parts does not yet come with an endorsed module that initializes the pkgs argument.""
        # So we must do this manually; https://flake.parts/overlays#consuming-an-overlay
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = lib.attrValues self.overlays;
          config.allowUnfree = true;
        };
      };
    };
}
