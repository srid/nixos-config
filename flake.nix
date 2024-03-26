{
  description = "Srid's NixOS / nix-darwin configuration";

  inputs = {
    # Principle inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-flake.url = "github:srid/nixos-flake";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    colmena-flake.url = "github:juspay/colmena-flake";

    # CI server
    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";
    nix-serve-ng.inputs.nixpkgs.follows = "nixpkgs";

    # Software inputs
    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-vscode-server.flake = false;
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    emanote.url = "github:srid/emanote";
    nixpkgs-match.url = "github:srid/nixpkgs-match";
    nuenv.url = "github:DeterminateSystems/nuenv";
    nixd.url = "github:nix-community/nixd";
    nixci.url = "github:srid/nixci";
    nix-browser.url = "github:juspay/nix-browser";
    actual.url = "github:srid/actual";
    actual.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.flake = false;
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # https://github.com/nix-community/nix-doom-emacs/issues/409#issuecomment-1753412481
    nix-straight = {
      url = "github:codingkoi/nix-straight.el/codingkoi/apply-librephoenixs-fix";
      flake = false;
    };
    nix-doom-emacs.inputs.nix-straight.follows = "nix-straight";

    # Devshell
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nixos-flake.flakeModule
        inputs.colmena-flake.flakeModules.default
        ./users
        ./home
        ./nixos
        ./nix-darwin
      ];

      colmena-parts.deployment =
        let
          read1Password = field:
            [ "op" "read" "op://Personal/nixos-config/${field}" ];
        in
        {
          github-runner = {
            targetHost = "github-runner";
            targetUser = "srid";
            keys."github-runner-token.secret" = {
              user = "github-runner";
              keyCommand = read1Password "github-runner-token";
            };
          };
        };

      flake = {
        # Configuration for my M1 Macbook Max (using nix-darwin)
        darwinConfigurations.appreciate =
          self.nixos-flake.lib.mkMacosSystem
            ./systems/darwin.nix;

        # Configuration for a NixOS VM (running on my Mac)
        nixosConfigurations = {
          github-runner = self.nixos-flake.lib.mkLinuxSystem
            ./systems/github-runner.nix;
        };
      };

      perSystem = { self', system, pkgs, lib, config, inputs', ... }: {
        # Flake inputs we want to update periodically
        # Run: `nix run .#update`.
        nixos-flake.primary-inputs = [
          "nixpkgs"
          "home-manager"
          "nix-darwin"
          "nixos-flake"
          "nix-index-database"
          "nixvim"
          "emacs-overlay"
          "nix-doom-emacs"
        ];

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
        };
        formatter = config.treefmt.build.wrapper;

        packages.default = self'.packages.activate;
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.treefmt.build.devShell ];
          packages = [
            pkgs.nixos-rebuild
            pkgs.just
            pkgs.colmena
          ];
        };
      };
    };
}
