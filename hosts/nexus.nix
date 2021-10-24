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
  # boot.extraModulePackages = [ config.boot.kernelPackages.rtl8821cu ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0c60d1a3-f5da-4687-a982-46a3c2580839";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/1642e4f1-8098-4db5-9327-5c5f8827a2c0";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/F0E7-9C8C";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # high-resolution display
  # hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; ## If compatibility with 32-bit applications is desired.

  services.xserver.videoDrivers = [ "nvidia" "intel" ];
  # On KDE+nvidia, display scaling can only be set here.
  services.xserver.dpi = 170;
  # Not sure how to merge two screens in KDE
  # cf. https://github.com/srid/nix-config/blob/master/device/p71/graphics.nix
  # These are the default.
  services.xserver.deviceSection = ''
    Option         "Twinview"
  '';
  services.xserver.serverLayoutSection = ''
    Option "Xinerama" "off"
  '';

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "srid" ];
  };

  networking.hostName = "nexus"; # Define your hostname.
  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services = {
    syncthing = {
      enable = true;
      user = "srid";
      dataDir = "/home/srid";
    };
  };

  programs = {
    mosh.enable = true;
    ssh.startAgent = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.srid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };

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
  system.stateVersion = "21.11"; # Did you read the comment?

}
