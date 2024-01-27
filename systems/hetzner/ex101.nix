{ flake, modulesPath, lib, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    flake.inputs.disko.nixosModules.disko
  ];
  system.stateVersion = "22.11";
  services.openssh.enable = true;
  boot = {
    loader.grub = {
      devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # For cross-compiling, https://discourse.nixos.org/t/how-do-i-cross-compile-a-flake/12062/4?u=srid
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  networking = {
    hostName = "actual";
    useDHCP = false;
    interfaces."eth0".ipv4.addresses = [
      {
        address = "167.235.115.189"; # your IPv4 here
        prefixLength = 24;
      }
    ];
    interfaces."eth0".ipv6.addresses = [
      {
        address = "2a01:4f8:2200:17c6::1"; # Your IPv6 here
        prefixLength = 64;
      }
    ];
    defaultGateway = "167.235.115.129";
    nameservers = [ "8.8.8.8" ];
  };
  disko.devices = import ./disko/two-raids-on-two-disks.nix {
    inherit lib;
  };
}
