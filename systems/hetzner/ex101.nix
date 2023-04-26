{ flake, modulesPath, lib, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    flake.inputs.disko.nixosModules.disko
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
    inherit lib;
  };
}
