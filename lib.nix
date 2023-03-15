# Support code for this repo. This module could be made its own external repo.
{ self, inputs, config, ... }:
let
  specialArgsFor = rec {
    common = {
      flake = { inherit inputs config; };
    };
    x86_64-linux = common // {
      system = "x86_64-linux";
    };
    aarch64-darwin = common // {
      system = "aarch64-darwin";
      rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
    };
  };
in
{
  flake = {
    # Linux home-manager module
    nixosModules.home-manager = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        ({
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgsFor.x86_64-linux;
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
          home-manager.extraSpecialArgs = specialArgsFor.aarch64-darwin;
        })
      ];
    };
    lib = {
      mkLinuxSystem = mod: inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        # Arguments to pass to all modules.
        specialArgs = specialArgsFor.${system};
        modules = [ mod ];
      };

      mkMacosSystem = mod: inputs.darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = specialArgsFor.${system};
        modules = [ mod ];
      };
    };
  };

  perSystem = { system, config, pkgs, lib, ... }: {
    mission-control.scripts = {
      update-primary = {
        description = ''
          Update primary flake inputs
        '';
        exec =
          let
            inputs = [ "nixpkgs" "home-manager" "darwin" ];
          in
          ''
            nix flake lock ${lib.foldl' (acc: x: acc + " --update-input " + x) "" inputs}
          '';
      };

      activate = {
        description = "Activate the current configuration for local system";
        exec =
          # TODO: Replace with deploy-rs or (new) nixinate
          if system == "aarch64-darwin" then
            ''
              cd "$(${lib.getExe config.flake-root.package})"
              ${self.darwinConfigurations.default.system}/sw/bin/darwin-rebuild \
                switch --flake .#default
            ''
          else
            ''
              ${lib.getExe pkgs.nixos-rebuild} --use-remote-sudo switch -j auto
            '';
        category = "Main";
      };

      fmt = {
        description = "Autoformat repo tree";
        exec = "nix fmt";
      };
    };
  };
}
