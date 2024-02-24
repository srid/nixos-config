{
  description = "Srid's NixOS / nix-darwin configuration";

  inputs = {
    # Principle inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.url = "github:LoganBarnett/nix-darwin/linux-builder-big-config"; # https://github.com/LnL7/nix-darwin/pull/878 (for 'systems')
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-flake.url = "github:srid/nixos-flake";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # CI server
    sops-nix.url = "github:juspay/sops-nix/json-nested"; # https://github.com/Mic92/sops-nix/pull/328
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
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # https://github.com/nix-community/nix-doom-emacs/issues/409#issuecomment-1753412481
    nix-straight = {
      url = "github:codingkoi/nix-straight.el?ref=codingkoi/apply-librephoenixs-fix";
      flake = false;
    };
    nix-doom-emacs.inputs.nix-straight.follows = "nix-straight";

    # Vim & its plugins (not in nixpkgs)
    zk-nvim.url = "github:mickael-menu/zk-nvim";
    zk-nvim.flake = false;
    coc-rust-analyzer.url = "github:fannheyward/coc-rust-analyzer";
    coc-rust-analyzer.flake = false;

    # Devshell
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nixos-flake.flakeModule
        ./users
        ./home
        ./nixos
        ./nix-darwin
      ];

      flake = {
        # Configurations for Linux (NixOS) systems
        nixosConfigurations = {
          linux-builder = self.nixos-flake.lib.mkLinuxSystem
            ./systems/linux-builder.nix;

          immediacy = self.nixos-flake.lib.mkLinuxSystem {
            imports = [
              self.nixosModules.default # Defined in nixos/default.nix
              inputs.sops-nix.nixosModules.sops
              ./systems/hetzner/ax41.nix
              ./nixos/server/harden
            ];
            sops.defaultSopsFile = ./secrets.json;
            sops.defaultSopsFormat = "json";
            services.tailscale.enable = true;
          };
        };

        # Configurations for my (only) macOS machine (using nix-darwin)
        darwinConfigurations = {
          appreciate = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "aarch64-darwin";
            imports = [
              self.darwinModules.default # Defined in nix-darwin/default.nix
              ./systems/darwin.nix
              ./systems/darwin/ci.nix
            ];
          };
          naivete = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "aarch64-darwin";
            imports = [
              self.darwinModules.default # Defined in nix-darwin/default.nix
              ./systems/darwin.nix
            ];
          };
        };
      };

      perSystem = { self', system, pkgs, lib, config, inputs', ... }: {
        nixos-flake.primary-inputs = [
          "nixpkgs"
          "home-manager"
          "nix-darwin"
          "nixos-flake"
          "nix-index-database"
        ];

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
        };

        packages.default = self'.packages.activate;
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixpkgs-fmt
            pkgs.sops
            pkgs.ssh-to-age
            pkgs.nixos-rebuild
            pkgs.just
          ];
        };
        formatter = config.treefmt.build.wrapper;
      };
    };
}
