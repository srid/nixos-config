/* My Linux VM running on macOS

  ## Using Parallels to create a NixOS VM

  - Boot into a NixOS graphical installer
  - Open terminal, and set a root password using `sudo su -` and `passwd root`
  - Authorize yourself to login to the root user using `ssh-copy-id -o PreferredAuthentications=password root@linux-builder`
  - Run nixos-anywhere (see justfile; `j remote-deploy`)
*/
{ flake, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    flake.inputs.disko.nixosModules.disko
    ../nixos/self/primary-as-admin.nix
    ../nixos/server/harden/basics.nix
  ];

  system.stateVersion = "23.11";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = [ "x86_64-linux" ]; # For cross-compiling
    swraid.mdadmConf = ''
      MAILADDR srid@srid.ca
    '';
  };
  nixpkgs.hostPlatform = "aarch64-linux";

  hardware.parallels.enable = true;
  nixpkgs.config.allowUnfree = true; # for parallels
  disko.devices = import ./disko/trivial.nix { device = "/dev/sda"; };

  networking = {
    hostName = "linux-builder";
    networkmanager.enable = true;
  };
  time.timeZone = "America/New_York";

  services = {
    openssh.enable = true;
    ntp.enable = true; # Accurate time in Parallels VM?
  };

  users.users.${flake.config.people.myself}.openssh.authorizedKeys.keys = [
    # macos /etc/ssh/ssh_host_ed25519_key.pub
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOPGfskkyhM0wefy0Sex2t5GENEHTIZAWrb9LzRN0R9x"
  ];
  nix.settings.trusted-users = [ "root" flake.config.people.myself ];
}
