# Support code for this repo. This module could be made its own external repo.
{ self, inputs, config, ... }:
{
  flake = {
    # Linux home-manager module
    nixosModules.home-manager = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        ({
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
            flake = { inherit config; };
          };
        })
      ];
    };
    # macOS home-manager module
    darwinModules.home-manager = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        ({
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "aarch64-darwin";
            flake = { inherit config; };
          };
        })
      ];
    };
    lib = {
      mkLinuxSystem = mod: inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        # Arguments to pass to all modules.
        specialArgs = {
          inherit system inputs;
          flake = { inherit config; };
        };
        modules = [ mod ];
      };

      mkMacosSystem = mod: inputs.darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs system;
          flake = { inherit config; };
          rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
        };
        modules = [ mod ];
      };
    };
  };

  perSystem = { system, pkgs, lib, ... }: {
    # TODO: replace these with mission-control
    apps =
      let
        # Create a flake app that wraps the given bash CLI.
        bashCmdApp = name: cmd: {
          type = "app";
          program =
            (pkgs.writeShellApplication {
              inherit name;
              text = ''
                set -x
                ${cmd}
              '';
            }) + "/bin/${name}";
        };
      in
      {
        # A rough app for activating the system locally.
        #
        # TODO: Replace with deploy-rs or (new) nixinate
        activate =
          if system == "aarch64-darwin" then
            bashCmdApp "darwin" ''
              ${self.darwinConfigurations.default.system}/sw/bin/darwin-rebuild \
              switch --flake ${self}#default
            ''
          else
            bashCmdApp "linux" ''
              ${lib.getExe pkgs.nixos-rebuild} --use-remote-sudo switch -j auto
            '';

        update-primary =
          let inputs = [ "nixpkgs" "home-manager" "darwin" ];
          in bashCmdApp "update-primary" ''
            nix flake lock ${lib.foldl' (acc: x: acc + " --update-input " + x) "" inputs}
          '';

      };
  };
}
