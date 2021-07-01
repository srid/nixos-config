{
  description = "Srid's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    # 
    # This ensures that we always use the official nix cache.
    nixpkgs.url = "github:nixos/nixpkgs/3a8d7958a610cd3fec3a6f424480f91a1b259185";

    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    himalaya.url = "github:soywod/himalaya";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-doom-emacs.url = "github:srid/nix-doom-emacs";
    emanote.url = "github:srid/emanote";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Make configuration for any computer I use in my home office.
      mkHomeMachine = configurationNix: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs; };
        modules = ([
          # System configuration
          configurationNix

          # Features common to all of my machines
          ./features/self-ide.nix
          ./features/caches
          ./features/current-location.nix
          ./features/passwordstore.nix
          ./features/syncthing.nix
          ./features/protonvpn.nix
          ./features/docker.nix
          ./features/monitor-brightness.nix
          ./features/ema/emanote.nix

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.srid = import ./home.nix {
              inherit inputs system;
              pkgs = import nixpkgs { inherit system; };
            };
          }
        ] ++ extraModules);
      };
    in
    {
      nixosConfigurations.p71 = mkHomeMachine
        ./hosts/p71.nix
        [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p53
          ./features/server-mode.nix
          # ./features/postgrest.nix
        ];
      nixosConfigurations.x1c7 = mkHomeMachine
        ./hosts/x1c7.nix
        [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
          ./features/email
          ./features/desktopish
          ./features/block-socialmedia.nix
        ];
    };
}
