{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      (../containers/hercules.nix)
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # Kernel w/ clear linux like patches: https://github.com/NixOS/nixpkgs/issues/63708#issuecomment-1003875463
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.supportedFilesystems = [ "ntfs" ];
  # https://notes.srid.ca/rtl8821cu
  # boot.extraModulePackages = [ config.boot.kernelPackages.rtl8821cu ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/25d3748c-b6fc-43d6-819a-e916821bd06e";
      fsType = "ext4";
    };
  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/ccc661bc-c59f-4172-b6e0-2ba54d34de5c";
  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/A782-D559";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; ## If compatibility with 32-bit applications is desired.

  services.xserver.videoDrivers = [ "nvidia" "intel" ];
  hardware.nvidia.modesetting.enable = true; # Required for Wayland+GDM, apparently.
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

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking.hostName = "thick"; # Define your hostname.
  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services = {
    syncthing = {
      enable = true;
      user = "srid";
      dataDir = "/home/srid";
    };
    neo4j = {
      enable = false;
    };
  };
  services.ipfs = {
    enable = false; # 8080 conflicts with playground-server
    autoMigrate = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
