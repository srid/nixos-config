{ config, pkgs, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];
  # https://notes.srid.ca/rtl8821cu
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8821cu ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/8d755446-15a4-4260-8a13-7529b585666b";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/68eed875-bd65-4178-bca6-3e1db074ed46";

  fileSystems."/boot" =
    {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };

  swapDevices = [ ];


  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; ## If compatibility with 32-bit applications is desired.
  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "srid" ];
  };

  networking.hostName = "p71"; # Define your hostname.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  services.openssh.enable = true;
  services.netdata.enable = true;

  programs = {
    mosh.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.srid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };
  users.users.srid.openssh.authorizedKeys.keys = import ./sshkeys.nix;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
