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
    nixos-flake.url = "github:srid/nixos-flake/deploy";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    ragenix.url = "github:yaxitech/ragenix";

    # Software inputs
    github-nix-ci.url = "github:juspay/github-nix-ci";
    nixos-vscode-server.flake = false;
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixci.url = "github:srid/nixci";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    actualism-app.url = "github:srid/actualism-app";

    # Neovim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Devshell
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nixos-flake.flakeModule
        inputs.nixos-flake.flakeModule
        ./users
        ./home
        ./nixos
        ./nix-darwin
      ];


      flake = {
        # Configuration for my M1 Macbook Max (using nix-darwin)
        darwinConfigurations.appreciate =
          self.nixos-flake.lib.mkMacosSystem
            ./systems/darwin.nix;

        # Hetzner dedicated
        nixosConfigurations.immediacy =
          self.nixos-flake.lib.mkLinuxSystem
            ./systems/ax41.nix;
      };

      perSystem = { self', inputs', pkgs, system, config, ... }: {
        # Flake inputs we want to update periodically
        # Run: `nix run .#update`.
        nixos-flake = {
          # https://github.com/srid/nixos-flake/pull/54
          deploy = {
            enable = true;
            sshTarget = "srid@immediacy";
          };
          primary-inputs = [
            "nixpkgs"
            "home-manager"
            "nix-darwin"
            "nixos-flake"
            "nix-index-database"
            "nixvim"
          ];
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
        };

        packages.default = self'.packages.activate;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.treefmt.build.devShell ];
          packages = with pkgs; [
            just
            colmena
            nixd
            inputs'.ragenix.packages.default
          ];
        };
        # Make our overlay available to the devShell
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (import ./packages/overlay.nix { inherit system; flake = { inherit inputs; }; })
          ];
        };
      };
    };
}
