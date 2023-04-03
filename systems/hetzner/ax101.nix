{ config, pkgs, lib, modulesPath, flake, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ahci" "usbhid" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a006ffe3-5d21-4439-8a00-a527beb18ff7";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 12;
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
    HOMEHOST pce
  '';

  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.services.swraid.mdadmConf = config.environment.etc."mdadm.conf".text;

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.firewall.checkReversePath = "loose"; # Tailscale recommends this

  networking.interfaces."enp7s0" = {
    ipv4 = {
      addresses = [{
        # Server main IPv4 address
        address = "85.10.192.137";
        prefixLength = 24;
      }];

      routes = [
        # Default IPv4 gateway route
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "85.10.192.129";
        }
      ];
    };

    ipv6 = {
      addresses = [{
        address = "2a01:4f8:a0:64e7::1";
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
    hostName = "pce";
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
  };

  services.netdata.enable = true;
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    lsof
    nil
    nixpkgs-fmt
  ];

  services.openssh.enable = true;

  services.nginx.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "srid@srid.ca";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${flake.config.people.myself} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "20.03";
}
