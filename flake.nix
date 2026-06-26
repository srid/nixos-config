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
    jumphost-nix.url = "github:srid/jumphost-nix";
    jumphost-nix.flake = false;

    # Pinned to PR #1568 (pulam-conn-bug): https://github.com/juspay/kolu/pull/1568
    kolu.url = "github:juspay/kolu/pulam-conn-bug";

    # drishti remote host monitor (home-manager module)
    # Pinned to PR #76 (adopt-shared-connection-cell): https://github.com/srid/drishti/pull/76
    drishti.url = "github:srid/drishti/adopt-shared-connection-cell";

    # Juspay's AI tooling repo. We consume only its opencode home-manager
    # module (config only, not the package) via homeModules.opencode.
    juspay-ai.url = "github:juspay/AI";
    juspay-ai.inputs.nixpkgs.follows = "nixpkgs";
    juspay-ai.inputs.llm-agents.follows = "llm-agents";

    # anywhen is NOT a flake input — it's deployed as an incus-pet
    # container, with the flake ref passed at deploy time (see
    # `just pureintent anywhen-deploy`). The host config doesn't import
    # anything from anywhen, so locking it here would just bloat
    # flake.lock without buying us anything.

    project-unknown.url = "github:juspay/project-unknown";
    project-unknown.inputs.nixpkgs.follows = "nixpkgs";

    # Source for opencode (see modules/home/work/opencode.nix).
    # NOTE: previously pinned to d9583b68 for claude-code 2.1.98 (newer
    # versions are nerfed; https://x.com/Sthiven_R/status/2043992488109899849),
    # but claude-code is no longer consumed from here (see
    # modules/home/claude-code), so we now track latest.
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Don't force nixpkgs.follows here: latest llm-agents needs a newer
    # nixpkgs than ours (e.g. pnpm_11), so let it use its own pinned nixpkgs.

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
