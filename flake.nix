{
  description = "Srid's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    # 
    # This ensures that we always use the official nix cache.
    nixpkgs.url = "github:nixos/nixpkgs/6d8215281b2f87a5af9ed7425a26ac575da0438f";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-vscode-server = {
      url = "github:iosmanthus/nixos-vscode-server/add-flake";
    };
    himalaya.url = "github:soywod/himalaya";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
    emanote.url = "github:srid/emanote/master";
    banyan.url = "github:srid/banyan/master";
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/stable";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, darwin, ... }:
    let
      system = "x86_64-linux";
      # Add nixpkgs overlays and config here. They apply to system and home-manager builds.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import inputs.emacs-overlay)
        ];
      };
      mkComputer = configurationNix: extraModules: nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs; };
        modules = (
          [
            # System configuration for this host
            configurationNix

            # Configuration common to all of my systems (servers, desktops, laptops)
            ./features/self-ide.nix
            ./features/takemessh
            ./features/caches
            ./features/current-location.nix
            #./features/passwordstore.nix

            # home-manager configuration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.srid = import ./home.nix
                {
                  inherit inputs system pkgs;
                };
            }
          ] ++ extraModules
        );
      };
    in
    {
      # The "name" in nixosConfigurations.${name} should match the `hostname`
      # 
      nixosConfigurations = {
        thick = mkComputer
          ./hosts/thick.nix
          [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p53
            ./features/server/harden.nix
            #./features/server/unlaptop.nix
            ./features/server/wakeonlan.nix
            #./features/server/devserver.nix
            ./features/gnome.nix
            ./features/desktopish/guiapps.nix
            #./features/desktopish/fonts.nix
            #./features/protonvpn.nix
            ./features/lxd.nix
            ./features/docker.nix
            ./features/postgres.nix
          ];
        thin = mkComputer
          ./hosts/thin.nix
          [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
            ./features/server/harden.nix
            ./features/distributed-build.nix
            ./features/gnome.nix
            ./features/desktopish/guiapps.nix
            ./features/desktopish/fonts.nix
            ./features/protonvpn.nix
            #./features/desktopish
          ];
        now = mkComputer
          ./hosts/hetzner/ax101.nix
          [
            ./features/server/harden.nix
            ./features/server/devserver.nix
          ];
      };

      darwinConfigurations."air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
          system = "aarch64-darwin";
          rosettaPkgs = import nixpkgs { system = "x86_64-darwin"; };
        };
        modules = [
          ./hosts/darwin.nix
          ./features/nix-direnv.nix
        ];
      };

      # non-NixOS systems
      homeConfigurations =
        let
          username = "srid";
          baseConfiguration = {
            programs.home-manager.enable = true;
            home.username = "srid";
            home.homeDirectory = "/home/srid";
          };
          mkHomeConfig = cfg: home-manager.lib.homeManagerConfiguration {
            inherit username system;
            homeDirectory = "/home/${username}";
            configuration = baseConfiguration // cfg;
          };
        in
        {
          # FIXME: This is broken on Clear Linux
          "x1c7" = mkHomeConfig {
            programs.git = import ./home/git.nix;
            programs.tmux = import ./home/tmux.nix;
          };
        };
    };

}
