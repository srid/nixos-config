{ config, pkgs, lib, inputs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ahci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/480156e1-b229-4f5b-883a-34b7e5a9e0e9";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 32;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "/dev/nvme1n1" "/dev/nvme0n1" ];
  };

  # The madm RAID was created with a certain hostname, which madm will consider
  # the "home hostname". Changing the system hostname will result in the array
  # being considered "foregin" as opposed to "local", and showing it as
  # '/dev/md/<hostname>:root0' instead of '/dev/md/root0'.

  # This is mdadm's protection against accidentally putting a RAID disk
  # into the wrong machine and corrupting data by accidental sync, see
  # https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14 and onward.
  # We set the HOMEHOST manually go get the short '/dev/md' names,
  # and so that things look and are configured the same on all such
  # machines irrespective of host names.
  # We do not worry about plugging disks into the wrong machine because
  # we will never exchange disks between machines.
  environment.etc."mdadm.conf".text = ''
    HOMEHOST now
  '';

  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.services.swraid.mdadmConf = config.environment.etc."mdadm.conf".text;

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;

  networking.interfaces."enp7s0" = {
    ipv4 = {
      addresses = [{
        # Server main IPv4 address
        address = "136.243.12.116";
        prefixLength = 24;
      }];

      routes = [
        # Default IPv4 gateway route
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "136.243.12.65";
        }
      ];
    };

    ipv6 = {
      addresses = [{
        address = "2a01:4f8:211:25c9::1";
        prefixLength = 64;
      }];

      # Default IPv6 route
      routes = [{
        address = "::";
        prefixLength = 0;
        via = "fe80::1";
      }];
    };
  };

  networking = {
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    hostName = "now";
  };

  nix = {
    # package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.netdata.enable = true;

  environment.systemPackages = with pkgs; [
    lsof
    inputs.nixos-shell.defaultPackage.${system}

    # Encrypted private directory stuff
    # See https://srid.ca/vf.enc
    cryptsetup
    (pkgs.writeShellApplication {
      name = "now-mount-priv";
      runtimeInputs = [ cryptsetup ];
      text = ''
        set -x
        sudo cryptsetup luksOpen /dev/nvme0n1p3 crypted0
        sudo mount /dev/mapper/crypted0 /extra0
      '';
    })
  ];

  services.openssh.permitRootLogin = "prohibit-password";
  services.openssh.enable = true;
  services.syncthing = {
    enable = true;
    user = "srid";
    dataDir = "/home/srid/priv/syncthing";
  };
  services.tailscale.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.srid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
