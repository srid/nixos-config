{
  description = "Srid's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    # 
    # This ensures that we always use the official nix cache.
    nixpkgs.url = "github:nixos/nixpkgs/b6966d911da89e5a7301aaef8b4f0a44c77e103c";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-vscode-server.url = "github:iosmanthus/nixos-vscode-server/add-flake";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/master";
    nixos-shell.url = "github:Mic92/nixos-shell";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, darwin, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlayModule =
        {
          nixpkgs.overlays = [
            (inputs.emacs-overlay.overlay)
            (inputs.neovim-nightly-overlay.overlay)
          ];
        };
      # Configuration common to all of my systems (servers, desktops, laptops)
      commonFeatures = [
        overlayModule
        ./features/self-ide.nix
        ./features/takemessh
        ./features/caches
        ./features/current-location.nix
      ];
      homeFeatures = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.srid = import ./home.nix
            {
              inherit inputs system pkgs;
            };
        }
      ];
      mkLinuxSystem = extraModules: nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs; };
        modules =
          commonFeatures ++ homeFeatures ++ extraModules;
      };
      mkMacosSystem = darwin.lib.darwinSystem;
    in
    {
      nixosConfigurations = {
        # My beefy development computer
        now = mkLinuxSystem
          [
            ./hosts/hetzner/ax101.nix
            ./features/server/harden.nix
            ./features/server/devserver.nix
            ./features/hercules.nix
          ];
        # This is run in qemu only.
        # > nixos-shell --flake github:srid/nixos-config#corsair
        corsair = pkgs.lib.makeOverridable nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = { inherit system inputs; };
          modules = [
            inputs.nixos-shell.nixosModules.nixos-shell
            {
              virtualisation = {
                memorySize = 8 * 1024;
                cores = 2;
                diskSize = 20 * 1024;
              };
              environment.systemPackages = with pkgs; [
                protonvpn-cli
                aria2
              ];
              nixos-shell.mounts = {
                mountHome = false;
                mountNixProfile = false;
                extraMounts."/Downloads" = {
                  target = "/home/srid/Downloads";
                  cache = "none";
                };
              };
            }
          ];
        };
      };

      darwinConfigurations."air" = mkMacosSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs system;
          rosettaPkgs = import nixpkgs { system = "x86_64-darwin"; };
        };
        modules = [
          overlayModule
          ./hosts/darwin.nix
          ./features/nix-direnv.nix
          ./features/caches/oss.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.srid = {
              home.stateVersion = "21.11";
            };
          }
        ];
      };
    };

}
