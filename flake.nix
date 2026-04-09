{
  description = "Srid's NixOS / nix-darwin configuration";


  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Principle inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-unified.url = "github:srid/nixos-unified";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs = {
      darwin.follows = "nix-darwin";
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };
    # Software inputs
    github-nix-ci.url = "github:juspay/github-nix-ci";
    nixos-vscode-server.flake = false;
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # vira.url = "github:juspay/vira/github";
    vira.url = "github:juspay/vira";
    # landrun-nix.url = "github:srid/landrun-nix";
    landrun-nix.url = "github:adrian-gierakowski/landrun-nix/darwin-implementation-via-sandbox-exec";
    nix-agent-wire.url = "github:srid/nix-agent-wire";
    jumphost-nix.url = "github:srid/jumphost-nix";
    jumphost-nix.flake = false;

    # KOLU
    kolu.url = "github:juspay/kolu/test/reconnect-repro-410";

    # Neovim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Emanote & Imako
    emanote.url = "github:srid/emanote";
    imako.url = "github:srid/imako";
    disc-scrape.url = "github:srid/disc-scrape";

    # Devshell
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.flake = false;
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
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
