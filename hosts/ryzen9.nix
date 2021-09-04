{ config, pkgs, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ahci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/1b31097e-364b-4f69-a576-08a7a57e3eab";
      fsType = "ext4";
    };

  swapDevices = [];

  nix.maxJobs = lib.mkDefault 32;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
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
    HOMEHOST ryzen9
  '';

  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.mdadmConf = config.environment.etc."mdadm.conf".text;

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;

  networking.interfaces."enp8s0" = {
    ipv4 = {
      addresses = [
        {
          # Server main IPv4 address
          address = "162.55.241.231";
          prefixLength = 24;
        }
      ];

      routes = [
        # Default IPv4 gateway route
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "162.55.241.193";
        }
      ];
    };

    ipv6 = {
      addresses = [
        {
          address = "2a01:4f8:272:4ec9::1";
          prefixLength = 64;
        }
      ];

      # Default IPv6 route
      routes = [
        {
          address = "::";
          prefixLength = 0;
          via = "fe80::1";
        }
      ];
    };
  };

  networking = {
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    hostName = "ryzen9";

  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "srid" ];
  };


  services = {
    openssh = {
      enable = true;
      # permitRootLogin = "no"; -- distributed-build.nix requires it
      passwordAuthentication = false;
    };
    fail2ban = {
      enable = true;
      ignoreIP = [
        # quebec
        "70.53.187.43"
      ];
    };

    netdata.enable = true;
  };

  programs = {
    mosh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    psmisc
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.srid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "adbusers" "audio" ];
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
  system.stateVersion = "20.03"; # Did you read the comment?

}
