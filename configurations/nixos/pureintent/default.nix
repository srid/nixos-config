{ flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@pureintent";
  # nixos-unified.sshTarget = "srid@192.168.2.134";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/linux/beszel.nix)
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/llm-debugging.nix)
    (self + /modules/nixos/linux/atuin.nix)
  ];

  # Inlined from the retired shared `my-workstation` profile. Remote access is
  # what must survive: openssh + tailscale, and the sudo rule that
  # `just activate` (over SSH, unprivileged user) depends on.
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
  services.tailscale.enable = true;
  # tailscaled installs its rules via iptables-nft, which live in a different
  # table from the nftables firewall incus requires.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # User services must start at boot without a login session.
  users.users.${flake.config.me.username}.linger = true;

  nix.settings = {
    sandbox = "relaxed";
    extra-experimental-features = [ "impure-derivations" "ca-derivations" ];
  };
  programs.nix-ld.enable = true; # for claude code / vscode server

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  home-manager.sharedModules = [
    "${homeMod}/cli/ssh-agent-forwarding.nix"
    "${homeMod}/cli/controlpersist.nix"
    "${homeMod}/cli/atuin.nix"

    # "${homeMod}/services/dropbox.nix"
    # "${homeMod}/services/obsidian.nix"
  ];

  # Prefer compressed in-RAM swap so page faults under build + Claude fleet
  # load become decompression instead of QLC disk I/O thrashing.
  # https://github.com/srid/nixos-config/issues/121
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  # Drop disk swap (install partition + prior 32G swapfile). Overflow onto a
  # DRAM-less QLC drive is what stalls the box; better to OOM-kill the runaway
  # process (earlyoom below) than thrash.
  swapDevices = lib.mkForce [ ];

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
