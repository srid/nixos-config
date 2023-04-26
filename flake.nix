{
  description = "Srid's NixOS configuration";

  inputs = {
    # Principle inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-flake.url = "github:srid/nixos-flake";
    disko.url = github:nix-community/disko;
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-flake.url = "path:/home/srid/code/nixos-flake";

    # CI server
    sops-nix.url = "github:Mic92/sops-nix";
    jenkins-nix-ci.url = "github:juspay/jenkins-nix-ci";
    hci.url = "github:hercules-ci/hercules-ci-agent";
    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";

    # Software inputs
    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.flake = false;
    emanote.url = "github:srid/emanote";
    nixpkgs-match.url = "github:srid/nixpkgs-match";
    nuenv.url = "github:DeterminateSystems/nuenv";
    devour-flake.url = "github:srid/devour-flake";
    devour-flake.flake = false;

    # Emacs
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";

    # Vim & its plugins (not in nixpkgs)
    zk-nvim.url = "github:mickael-menu/zk-nvim";
    zk-nvim.flake = false;
    coc-rust-analyzer.url = "github:fannheyward/coc-rust-analyzer";
    coc-rust-analyzer.flake = false;
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit (inputs) self; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        inputs.nixos-flake.flakeModule
        ./users
        ./home
        ./nixos
        ./nix-darwin
      ];

      flake = {
        # Configurations for Linux (NixOS) systems
        nixosConfigurations = {
          actual = self.nixos-flake.lib.mkLinuxSystem ({ modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/scan/not-detected.nix")
              self.nixosModules.default # Defined in nixos/default.nix
              inputs.disko.nixosModules.disko
            ];
            system.stateVersion = "22.11";
            services.openssh.enable = true;
            boot.loader.grub = {
              devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
              efiSupport = true;
              efiInstallAsRemovable = true;
            };
            boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
            nixpkgs.hostPlatform = "x86_64-linux";
            # powerManagement.cpuFreqGovernor = "ondemand";
            hardware.cpu.intel.updateMicrocode = true;
            hardware.enableRedistributableFirmware = true;

            networking.hostName = "actual";
            networking.useDHCP = false;
            networking.interfaces."eth0".ipv4.addresses = [
              {
                address = "167.235.115.189"; # your IPv4 here
                prefixLength = 24;
              }
            ];
            networking.interfaces."eth0".ipv6.addresses = [
              {
                address = "2a01:4f8:2200:17c6::1"; # Your IPv6 here
                prefixLength = 64;
              }
            ];
            networking.defaultGateway = "167.235.115.129";
            networking.nameservers = [ "8.8.8.8" ];
            disko.devices = import ./disko/two-raids-on-two-disks.nix {
              lib = inputs.nixpkgs.lib;
            };
          });
          pce = self.nixos-flake.lib.mkLinuxSystem {
            imports = [
              self.nixosModules.default # Defined in nixos/default.nix
              inputs.sops-nix.nixosModules.sops
              ./systems/hetzner/ax101.nix
              ./nixos/server/harden.nix
              ./nixos/docker.nix
              ./nixos/jenkins.nix
            ];
            sops.defaultSopsFile = ./secrets.yaml;
          };
        };

        # Configurations for my (only) macOS machine (using nix-darwin)
        darwinConfigurations = {
          appreciate = self.nixos-flake.lib.mkARMMacosSystem {
            imports = [
              self.darwinModules.default # Defined in nix-darwin/default.nix
              ./nixos/hercules.nix
              ./systems/darwin.nix
            ];
          };
        };
      };

      perSystem = { self', system, pkgs, lib, config, inputs', ... }: {
        packages.default = self'.packages.activate;
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nixpkgs-fmt
            pkgs.sops
            pkgs.ssh-to-age

          ] ++ lib.optionals (system == "x86_64-linux") [ self.nixosConfigurations."pce".config.jenkins-nix-ci.nix-prefetch-jenkins-plugins ];
        };
        formatter = pkgs.nixpkgs-fmt;
      };
    };
}
