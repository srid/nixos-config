{ config, flake, lib, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@naiveintent";
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

  imports = [
    self.nixosModules.default
    ./configuration.nix
    # pu + proxychains (needs jumphost SOCKS5 from juspay.nix below)
    (self + /configurations/nixos/pureintent/devbox.nix)
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/llm-debugging.nix)
  ];

  users.users.${flake.config.me.username}.linger = true;
  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
    # Jump host SOCKS5 (jumphost-nix) — required by pu / juspay-run
    "${homeMod}/work/juspay.nix"
    "${homeMod}/nix/gc.nix"
  ];

  nix.settings = {
    sandbox = "relaxed";
    extra-experimental-features = [ "impure-derivations" "ca-derivations" ];
  };
  # GC: system generations via modules/nixos/linux/gc.nix (root-owned);
  # user profile via home-manager (modules/home/nix/gc.nix).

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64 * 1024; # 32GB in megabytes
  }];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  # tailscaled installs its rules via iptables-nft, which live in a different
  # table from the nftables firewall that incus requires. Adding tailscale0 here
  # gets it into the nftables trusted-interfaces set too.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedTCPPorts = [
    80
    443
    7692
  ];

  programs.nix-ld.enable = true; # for claude code

  # HACK: system package so kolu MCP works on remote hosts (PATH / nix-ld), not the
  # full services.kolu user service (see modules/home/services/kolu.nix on pureintent).
  environment.systemPackages = [
    inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
