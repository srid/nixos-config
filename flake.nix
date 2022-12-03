{
  description = "Srid's NixOS configuration";

  inputs = {
    # Principle inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Supportive inputs
    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Software inputs
    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.flake = false;
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/master";
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";
    emanote.url = "github:EmaApps/emanote";

    # Vim & its plugins (not in nixpkgs)
    zk-nvim.url = "github:mickael-menu/zk-nvim";
    zk-nvim.flake = false;
    coc-rust-analyzer.url = "github:fannheyward/coc-rust-analyzer";
    coc-rust-analyzer.flake = false;
  };

  outputs = inputs@{ self, home-manager, nixpkgs, darwin, ... }:
    inputs.flake-parts.lib.mkFlake { inherit (inputs) self; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [ ];
      perSystem = { self', inputs', config, pkgs, lib, system, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            # To enable webhint to analyze source files
            nodejs
          ];
        };
        formatter = pkgs.nixpkgs-fmt;
        apps.default =
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
          if system == "aarch64-darwin" then
            bashCmdApp "darwin" ''
              ${self.darwinConfigurations.default.system}/sw/bin/darwin-rebuild \
                switch --flake ${self}#default
            ''
          else
            bashCmdApp "linux" ''
              ${lib.getExe pkgs.nixos-rebuild} --use-remote-sudo switch -j auto
            '';
      };
      flake =
        let
          userName = "srid";
        in
        {
          # Configuration common to all Linux systems
          nixosModules = {
            common.imports = [
              ./nixos/caches
            ];
            home.imports = [
              home-manager.nixosModules.home-manager
              ({
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  system = "x86_64-linux";
                };
              })
            ];
            default.imports =
              self.nixosModules.common.imports ++
              self.nixosModules.home.imports ++
              [
                ./nixos/self-ide.nix
                ./nixos/takemessh
                ./nixos/current-location.nix
              ];
          };
          # Configuration common to all macOS systems
          darwinModules = {
            common = self.nixosConfig.common;
            home.imports = [
              home-manager.darwinModules.home-manager
              ({
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  system = "aarch64-darwin";
                };
              })
            ];
            default.imports =
              self.darwinModules.common ++
              self.darwinModules.home.imports;
          };
          homeModules = {
            common = {
              home.stateVersion = "22.11";
              imports = [
                ./home/tmux.nix
                ./home/neovim.nix
                ./home/emacs.nix
                ./home/starship.nix
                ./home/terminal.nix
                ./home/direnv.nix
              ];
            };
            common-linux = {
              imports = [
                self.homeModules.common
                ./home/vscode-server.nix
              ];
              programs.bash.enable = true;
            };
            common-darwin = {
              imports = [
                self.homeModules.common
              ];
              programs.zsh = {
                enable = true;
                initExtra = ''
                  export PATH=/etc/profiles/per-user/${userName}/bin:/run/current-system/sw/bin/:$PATH
                '';
              };
            };
          };
          # Configurations for Linux (NixOS) systems
          nixosConfigurations =
            let
              homeModules = [
                {
                  home-manager.users.${userName} = { pkgs, ... }: {
                    imports = [
                      self.homeModules.common-linux
                      (import ./home/git.nix {
                        userName = "Sridhar Ratnakumar";
                        userEmail = "srid@srid.ca";
                      })
                      ./home/shellcommon.nix
                    ];
                  };
                }
              ];
              mkLinuxSystem = extraModules: nixpkgs.lib.nixosSystem rec {
                system = "x86_64-linux";
                # Arguments to pass to all modules.
                specialArgs = { inherit system inputs; };
                modules =
                  [ self.nixosModules.default ] ++ homeModules ++ extraModules;
              };
            in
            {
              # My Linux development computer (on Hetzner)
              pinch = mkLinuxSystem
                [
                  ./systems/hetzner/ax41.nix
                  ./nixos/server/harden.nix

                  # Temporarily sharing with Uday.
                  {
                    users.users.uday.isNormalUser = true;
                    home-manager.users."uday" = {
                      imports = [
                        self.homeModules.common-linux
                        (import ./home/git.nix {
                          userName = "Uday Kiran";
                          userEmail = "udaycruise2903@gmail.com";
                        })
                      ];
                    };
                  }
                ];
            };

          # Configurations for macOS systems (using nix-darwin)
          darwinConfigurations =
            let
              mkMacosSystem = darwin.lib.darwinSystem;
              defaultMacosSystem = mkMacosSystem rec {
                system = "aarch64-darwin";
                specialArgs = {
                  inherit inputs system;
                  rosettaPkgs = import nixpkgs { system = "x86_64-darwin"; };
                };
                modules = [
                  self.darwinModules.default
                  ./systems/darwin.nix
                  {
                    home-manager.users.${userName} = { pkgs, ... }: {
                      imports = [
                        self.homeModules.common-darwin
                        (import ./home/git.nix {
                          userName = "Sridhar Ratnakumar";
                          userEmail = "srid@srid.ca";
                        })
                        ./home/shellcommon.nix
                      ];
                    };
                  }
                ];
              };
            in
            {
              default = defaultMacosSystem;
            };
        };
    };
}
