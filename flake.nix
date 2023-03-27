{
  description = "Srid's NixOS configuration";

  inputs = {
    # Principle inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-flake.url = "github:srid/nixos-flake";
    jenkins-nix-ci.url = "github:juspay/jenkins-nix-ci/flake-module";
    flake-root.url = "github:srid/flake-root";
    jenkinsPlugins2nix.url = "github:Fuuzetsu/jenkinsPlugins2nix";
    # nixos-flake.url = "path:/Users/srid/code/nixos-flake";

    # CI server
    hci.url = "github:hercules-ci/hercules-ci-agent";
    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";

    # Software inputs
    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.flake = false;
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";
    emanote.url = "github:srid/emanote";
    nixpkgs-match.url = "github:srid/nixpkgs-match";

    # Emacs
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # Vim & its plugins (not in nixpkgs)
    zk-nvim.url = "github:mickael-menu/zk-nvim";
    zk-nvim.flake = false;
    coc-rust-analyzer.url = "github:fannheyward/coc-rust-analyzer";
    coc-rust-analyzer.flake = false;
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit (inputs) self; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.nixos-flake.flakeModule
        inputs.jenkins-nix-ci.flakeModule
        inputs.flake-root.flakeModule
        ./users
        ./home
        ./nixos
        ./nix-darwin
      ];

      jenkins-nix-ci = {
        domain = "jenkins.srid.ca";
        plugins = [
          "github-api"
          "git"
          "github-branch-source"
          "workflow-aggregator"
          "ssh-slaves"
          "configuration-as-code"
        ];
        plugins-file = "nixos/jenkins/plugins.nix";
      };

      flake = {
        # Configurations for Linux (NixOS) systems
        nixosConfigurations = {
          pce = self.nixos-flake.lib.mkLinuxSystem {
            imports = [
              self.nixosModules.default # Defined in nixos/default.nix
              self.nixosModules.jenkins-master
              inputs.sops-nix.nixosModules.sops
              ./systems/hetzner/ax101.nix
              ./nixos/server/harden.nix
              ./nixos/docker.nix
              ./nixos/jenkins.nix
              # ./nixos/hercules.nix
              # I host a Nix cache
              # (import ./nixos/cache-server.nix {
              #   keyName = "cache-priv-key";
              #   domain = "cache.srid.ca";
              # })
            ];
            sops.defaultSopsFile = ./secrets.yaml;
          };
        };

        # Configurations for my (only) macOS machine (using nix-darwin)
        darwinConfigurations = {
          appreciate = self.nixos-flake.lib.mkARMMacosSystem {
            imports = [
              self.darwinModules.default # Defined in nix-darwin/default.nix
              ./nixos/hercules.nix
              ./systems/darwin.nix
            ];
          };
        };
      };

      perSystem = { self', pkgs, config, inputs', ... }: {
        packages.default = self'.packages.activate;
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nixpkgs-fmt
            pkgs.sops
            pkgs.ssh-to-age
            inputs'.agenix.packages.agenix
          ];
        };
        formatter = pkgs.nixpkgs-fmt;
      };
    };
}
