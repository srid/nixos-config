# MINISFORUM MS-A2: Ryzen 9 9955HX (16C/32T), 60 GiB RAM, Radeon iGPU,
# dual Intel X710 10G + Realtek/Intel 2.5G, MT7921 Wi-Fi/Bluetooth.
# Adopted from the stock NixOS 26.05 install; see README.md.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # DHCP address on the LAN; switch to `srid@pce` once MagicDNS/tailnet
  # resolves the hostname.
  nixos-unified.sshTarget = "srid@192.168.2.56";

  imports = [
    self.nixosModules.default
    (self + /k8s/odu-lane.nix)
    (self + /modules/nixos/cache.nix)
    (self + /modules/nixos/linux/gc.nix)
    ./configuration.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";

  # Remote access is what must survive: openssh + tailscale, and the sudo rule
  # that `just activate pce` (over SSH, unprivileged user) depends on.
  nixos-unified.localPrivilegeMode = "sudo-nixos-rebuild";
  security.sudo.extraRules = [
    {
      users = [ flake.config.me.username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild switch *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.openssh.enable = true;

  # Not enrolled unattended: run `tailscale up` once after the install.
  services.tailscale.enable = true;

  # amdgpu/MT7921 firmware and AMD microcode.
  hardware.enableRedistributableFirmware = true;
}
