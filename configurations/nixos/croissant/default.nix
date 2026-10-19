# OVHcloud dedicated server (RISE-S, Ryzen 7 9700X, 64 GB, 2x512 GB NVMe).
# Installed via nixos-anywhere from the OVH rescue system; see README.md.
{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "root@37.187.28.109";

  imports = [
    inputs.disko.nixosModules.disko
    self.nixosModules.default
    ./hardware-configuration.nix
    ./disko.nix
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/docker.nix)
  ];

  networking.hostName = "croissant";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  # UEFI box, but install GRUB as the removable-media fallback so it boots
  # without touching OVH's firmware boot entries. One ESP per disk so either
  # NVMe can boot on its own.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "/dev/nvme0n1" ]; path = "/boot"; }
      { devices = [ "/dev/nvme1n1" ]; path = "/boot-fallback"; }
    ];
  };
  boot.swraid.enable = true;
  boot.swraid.mdadmConf = "MAILADDR root";
  # Headless box: let the OVH KVM get a root shell if the initrd fails
  # (otherwise sulogin refuses with "root account is locked").
  boot.initrd.systemd.emergencyAccess = true;

  # OVH networking: IPv4 is handed out by OVH's DHCP (gateway .254). IPv6 is
  # static; the gateway sits outside our /64, which NixOS handles via
  # defaultGateway6.interface.
  networking.useDHCP = false;
  networking.interfaces.enp6s0 = {
    useDHCP = true;
    ipv6.addresses = [{ address = "2001:41d0:a:1c6d::1"; prefixLength = 64; }];
  };
  networking.defaultGateway6 = {
    address = "2001:41d0:a:1cff:ff:ff:ff:ff";
    interface = "enp6s0";
  };
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Public SSH: root only, key only. The `srid` user (primary-as-admin.nix)
  # is reached over Tailscale instead.
  services.openssh = {
    enable = true;
    allowSFTP = false;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [ "root" ];
    };
    # From the tailnet, also allow the primary user.
    extraConfig = ''
      Match Address 100.64.0.0/10,fd7a:115c:a1e0::/48
        AllowUsers root ${flake.config.me.username} ci
    '';
  };
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Joins the tailnet unattended on first boot. The auth key is decrypted by
  # agenix with the host key seeded at install time.
  age.secrets."tailscale-authkey".file = self + /secrets/tailscale-authkey.age;
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets."tailscale-authkey".path;
    extraSetFlags = [ "--operator=${flake.config.me.username}" ];
  };

  # odu CI lane (modules/home/cli/odu.nix lists ci@croissant). Builders need
  # only SSH access and Nix; reachable over the tailnet like srid.
  users.users.ci = {
    isNormalUser = true;
    description = "odu CI lane";
    extraGroups = [ "docker" ];
    openssh.authorizedKeys.keys = [
      flake.config.me.sshKey
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnWriRB3c/G+O4/N5ALnOQBdBTp9LeGC6HNYTZCCGS2 srid@pureintent"
    ];
  };
  environment.systemPackages = [ pkgs.git ];

  zramSwap.enable = true;
}
