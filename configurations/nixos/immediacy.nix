# Hetzner dedicated: AX41-NVMe
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    self.nixosModules.default
    "${self}/modules/nixos/linux/disko/trivial.nix"
    "${self}/modules/nixos/linux/docker.nix"
    "${self}/modules/nixos/linux/actualism-app.nix"
    "${self}/modules/nixos/linux/hedgedoc.nix"
    "${self}/modules/nixos/linux/server/harden/basics.nix"
    "${self}/modules/nixos/shared/github-runner.nix"
  ];

  nixos-flake.sshTarget = "srid@immediacy";

  system.stateVersion = "23.11";
  networking.hostName = "immediacy";
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.loader.grub = {
    devices = [ "/dev/nvme0n1" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Hetzner networking
  networking.useDHCP = false;
  networking.interfaces."eth0".ipv4.addresses = [
    {
      address = "65.109.84.215"; # your IPv4 here
      prefixLength = 24;
    }
  ];
  networking.interfaces."eth0".ipv6.addresses = [
    {
      address = "2a01:4f9:3051:52d3::2"; # Your IPv6 here
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "65.109.84.193";
  networking.nameservers = [ "8.8.8.8" ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  programs.nix-ld.enable = true; # for vscode server
}
