{ flake, modulesPath, lib, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    flake.inputs.disko.nixosModules.disko
    ./nixos-container.nix
  ];
  system.stateVersion = "23.11";
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
    hostName = "immediacy";
    useDHCP = false;
    interfaces."eth0".ipv4.addresses = [
      {
        address = "65.109.35.172"; # your IPv4 here
        prefixLength = 24;
      }
    ];
    interfaces."eth0".ipv6.addresses = [
      {
        address = "2a01:4f9:5a:2120::2"; # Your IPv6 here
        prefixLength = 64;
      }
    ];
    defaultGateway = "65.109.35.129";  # `ip route | grep default`
    nameservers = [ "8.8.8.8" ];
  };
  disko.devices = import ./disko/two-raids-on-two-disks.nix {
    inherit lib;
  };
}
