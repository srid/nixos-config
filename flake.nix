{
  description = "Srid's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    # 
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/a73020b2a150322c9832b50baeb0296ba3b13dd7";

    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    himalaya.url = "github:srid/himalaya/nixify-crate2nix";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
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
          ./features/passwordstore.nix
          ./features/syncthing.nix
          ./features/email
          ./features/emacs.nix
          ./features/monitor-brightness.nix

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.srid = import ./home.nix;
          }
        ] ++ extraModules);
      };
    in
    {
      nixosConfigurations.p71 = mkHomeMachine
        ./hosts/p71.nix
        [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p53
          ./features/desktopish
          # ./features/virtualization.nix
          ./features/postgrest.nix
        ];
      nixosConfigurations.x1c7 = mkHomeMachine
        ./hosts/x1c7.nix
        [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
        ];
    };
}
