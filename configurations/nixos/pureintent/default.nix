{ config, flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
  # pu-managed CI fleet (kolu-ci-1 .. kolu-ci-8). These are ssh_config aliases
  # provided by `pu` (Include ~/.pu-state/*/ssh_config) and are reachable only
  # from pureintent, so drishti monitors them from here.
  ciHosts = map (n: "kolu-ci-${toString n}") (lib.range 1 8);
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
    ./devbox.nix
    (self + /modules/nixos/linux/beszel.nix)
    (self + /modules/nixos/linux/incus)
    (self + /modules/nixos/linux/llm-debugging.nix)
  ];

  # anywhen runs as an incus-pet container (see modules/nixos/linux/incus/incus-pet).
  # Deployed with:
  #   incus-pet deploy github:srid/anywhen --port 6111 --listen 100.122.32.106

  # Expose the incus UI on the Tailscale interface only.
  virtualisation.incus.preseed.config."core.https_address" = "100.122.32.106:8443";

  users.users.${flake.config.me.username}.linger = true;
  home-manager.sharedModules = [
    "${homeMod}/cli/ssh-agent-forwarding.nix"
    "${homeMod}/cli/controlpersist.nix"
    "${homeMod}/claude-code"
    "${homeMod}/work/juspay.nix"
    "${homeMod}/work/opencode.nix"
    "${homeMod}/services/vira.nix"
    "${homeMod}/services/kolu.nix"
    "${homeMod}/services/drishti"
    {
      services.kolu.host = "100.122.32.106"; # Tailscale IP of pureintent
      # Browser origin differs from the Host kolu sees (served via Tailscale
      # MagicDNS reverse proxy), so allow it for the CSWSH origin gate.
      services.kolu.allowedOrigins = [ "https://pureintent.rooster-blues.ts.net" ];
      # Watch the pu-managed CI fleet from here (only reachable from pureintent).
      services.drishti.hosts = [ "localhost" ] ++ ciHosts;
    }

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

  # Workaround `nixos-rebuild switch` hanging at "reloading the following units:
  # dbus-broker.service". The reload step stalls (broker has long-lived clients
  # holding the bus); skip reload/restart during activation. Bus policy changes
  # land on next boot instead. Same applies to the per-user broker
  # (`Failed to reload user unit dbus-broker.service` → exit 4).
  systemd.services.dbus-broker.reloadIfChanged = lib.mkForce false;
  systemd.services.dbus-broker.restartIfChanged = lib.mkForce false;
  systemd.user.services.dbus-broker.reloadIfChanged = lib.mkForce false;
  systemd.user.services.dbus-broker.restartIfChanged = lib.mkForce false;
}
