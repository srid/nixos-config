{
  description = "Srid's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    himalaya.url = "github:srid/himalaya/nixify";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }: 
    let 
      system = "x86_64-linux";
      # Make configuration for any computer I use in my home office.
      mkHomeMachine = configurationNix: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # System configuration
          configurationNix
          ./modules/passwordstore.nix
          ./modules/syncthing.nix
          ./modules/protonmail-bridge.nix
          ./modules/monitor-brightness.nix

          # Packages from flake inputs
          ({ pkgs, lib, ... }: {
            environment.systemPackages = 
              let 
                # Wrap himalaya to be aware of ProtonMail's bridge cert.
                himalaya = lib.getAttrFromPath [system] inputs.himalaya.defaultPackage;
                himalayaWithSslEnv = 
                  pkgs.writeScriptBin "h" ''
                    #!${pkgs.stdenv.shell}
                    export SSL_CERT_FILE=~/.config/protonmail/bridge/cert.pem
                    exec ${himalaya}/bin/himalaya
                    '';
              in [
                himalayaWithSslEnv
              ];
          })

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.srid = import ./home.nix;
          }
        ];
      };
    in {
      nixosConfigurations.p71 = mkHomeMachine ./p71/configuration.nix;
      nixosConfigurations.x1c7 = mkHomeMachine ./x1c7/configuration.nix;
    };
}
