{
  description = "Srid's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.flake = false;
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/master";
    nixos-shell.url = "github:Mic92/nixos-shell";

    # Vim & its plugins (not in nixpkgs)
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.neovim-flake.url = "github:neovim/neovim/v0.7.0?dir=contrib";
    vim-eldar.url = "github:agude/vim-eldar";
    vim-eldar.flake = false;
    himalaya.url = "github:soywod/himalaya";
    himalaya.flake = false;
    zk-nvim.url = "github:mickael-menu/zk-nvim";
    zk-nvim.flake = false;
    coc-rust-analyzer.url = "github:fannheyward/coc-rust-analyzer";
    coc-rust-analyzer.flake = false;
  };

  outputs = inputs@{ self, home-manager, nixpkgs, darwin, ... }:
    let
      overlayModule =
        {
          nixpkgs.overlays = [
            (inputs.neovim-nightly-overlay.overlay)
          ];
        };
    in
    {
      # Configurations for Linux (NixOS) systems
      nixosConfigurations =
        let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system};
          # Configuration common to all Linux systems
          commonFeatures = [
            overlayModule
            ./nixos/self-ide.nix
            ./nixos/takemessh
            ./nixos/caches
            ./nixos/current-location.nix
          ];
          homeFeatures = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit system inputs; };
              home-manager.users.srid = {
                imports = [
                  ./home/tmux.nix
                  ./home/git.nix
                  ./home/neovim.nix
                  ./home/starship.nix
                  ./home/terminal.nix
                  ./home/direnv.nix
                  ./home/vscode-server.nix
                ];

                programs.bash = {
                  enable = true;
                } // (import ./home/shellcommon.nix { inherit pkgs; });
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
        in
        {
          # My beefy development computer
          now = mkLinuxSystem
            [
              ./systems/hetzner/ax101.nix
              ./nixos/server/harden.nix
              ./nixos/hercules.nix
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

      # Configurations for macOS systems (using nix-darwin)
      darwinConfigurations =
        let
          system = "aarch64-darwin";
          mkMacosSystem = darwin.lib.darwinSystem;
          defaultMacosSystem = mkMacosSystem {
            inherit system;
            specialArgs = {
              inherit inputs system;
              rosettaPkgs = import nixpkgs { system = "x86_64-darwin"; };
            };
            modules = [
              overlayModule
              ./systems/darwin.nix
              ./nixos/caches/oss.nix
              home-manager.darwinModules.home-manager
              {
                home-manager.extraSpecialArgs = { inherit system inputs; };
                home-manager.users.srid = { pkgs, ... }: {
                  imports = [
                    ./home/git.nix
                    ./home/tmux.nix
                    ./home/neovim.nix
                    ./home/email.nix
                    ./home/terminal.nix
                    ./home/direnv.nix
                    ./home/starship.nix
                  ];
                  programs.zsh = {
                    enable = true;
                    initExtra = ''
                      export PATH=$HOME/.nix-profile/bin:/run/current-system/sw/bin/:$PATH
                    '';
                  } // (import ./home/shellcommon.nix { inherit pkgs; });
                  home.stateVersion = "21.11";
                };
              }
            ];
          };
        in
        {
          # These are indexed, by convention, using hostnames.
          # For example, if `sky.local` is the hostname of your Mac, then use
          # `sky` here.
          air = defaultMacosSystem;
          sky = defaultMacosSystem;
        };


    } //
    inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            treefmt
            nixpkgs-fmt
            # To enable webhint to analyze source files
            nodejs
          ];
        };
      }
    );

}
