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
      imports = [
        ./home
        ./nixos
        ./nix-darwin
      ];
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
          # Configurations for Linux (NixOS) systems
          nixosConfigurations = {
            # My Linux development computer (on Hetzner)
            pinch = self.lib.mkLinuxSystem userName
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
          darwinConfigurations = {
            default = self.lib-darwin.mkMacosSystem userName;
          };
        };
    };
}
