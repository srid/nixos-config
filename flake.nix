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
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
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
    jumphost-nix.url = "github:srid/jumphost-nix";
    jumphost-nix.flake = false;

    kolu.url = "github:juspay/kolu/master";
    drishti.url = "github:srid/drishti";
    olai.url = "github:juspay/olai/master";

    # Juspay's AI tooling: OMP, Codex and Claude Code, carrying juspay/skills +
    # kolu over Juspay's LiteLLM gateway. A single-profile distribution built on
    # juspay/agent-distro; installed by modules/home/work/pi.nix.
    juspay-ai.url = "github:juspay/AI";
    agent-distro.url = "github:juspay/agent-distro";

    xyne-boxes.url = "github:juspay/xyne-boxes/list-refresh-ssh-config";
    xyne-boxes.inputs.nixpkgs.follows = "nixpkgs";

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
      imports = map
        (fn: ./modules/flake-parts/${fn})
        (builtins.attrNames (builtins.readDir ./modules/flake-parts));

      perSystem = { system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
}
