{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "srid";
  syschdemd = import ./thebeast/syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.hostName = "thebeast";
  networking.dhcpcd.enable = false;

  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # https://github.com/NixOS/nixpkgs/issues/124753#issuecomment-851618324
  nixpkgs.overlays =
    let pinentry_only_curses = self: super: {
      pinentry = super.pinentry.override {
        enabledFlavors = [ "curses" ];
      };
    };
    in
    [
      pinentry_only_curses
    ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services = {
    syncthing = {
      enable = true;
      user = "srid";
      dataDir = "/home/srid";
    };
  };


  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
}
