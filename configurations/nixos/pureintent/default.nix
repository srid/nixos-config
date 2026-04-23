{ config, flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@pureintent";
  # nixos-unified.sshTarget = "srid@192.168.2.134";
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
    (self + /modules/nixos/linux/beszel.nix)
    (self + /modules/nixos/linux/incus)
  ];

  # Expose the incus UI on the Tailscale interface only.
  virtualisation.incus.preseed.config."core.https_address" = "100.122.32.106:8443";

  users.users.${flake.config.me.username}.linger = true;
  home-manager.sharedModules = [
    "${homeMod}/cli/ssh-agent-forwarding.nix"
    "${homeMod}/cli/controlpersist.nix"
    "${homeMod}/claude-code"
    "${homeMod}/work/juspay.nix"
    "${homeMod}/services/vira.nix"
    "${homeMod}/services/kolu.nix"

    # "${homeMod}/services/dropbox.nix"
    # "${homeMod}/services/obsidian.nix"

    # Remote builders
    "${homeMod}/nix/buildMachines"
    "${homeMod}/nix/buildMachines/sincereintent.nix"

    "${homeMod}/nix/gc.nix"
  ];

  nix.settings = {
    sandbox = "relaxed";
    extra-experimental-features = [ "impure-derivations" "ca-derivations" ];
  };
  # GC is handled via home-manager (modules/home/nix/gc.nix)

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB in megabytes
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
  ];

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
