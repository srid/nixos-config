# Shared profile for my deployed Linux workstations (pureintent, naiveintent).
#
# These two hosts are deployed the same way (`just activate` over SSH, as a
# non-root user) and run the same working set. Everything that was identical
# in both host files lives here; the host files keep only what genuinely
# differs (sshTarget, hostname, swap policy, extra ports/modules).
{ flake, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  # Deploying over SSH as an unprivileged user needs both halves: the mode
  # tells nixos-unified to shell out to sudo, and the sudo rule makes that
  # non-interactive. Keep them together — one without the other makes
  # `just activate` prompt or fail.
  nixos-unified.localPrivilegeMode = "sudo-nixos-rebuild";
  security.sudo.extraRules = [
    {
      users = [ config.me.username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild switch *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # home-manager user services (kolu, drishti, olai, …) must start at boot
  # without a login session.
  users.users.${config.me.username}.linger = true;

  nix.settings = {
    sandbox = "relaxed";
    extra-experimental-features = [ "impure-derivations" "ca-derivations" ];
  };
  # GC: system generations via modules/nixos/linux/gc.nix (root-owned);
  # user profile via home-manager (modules/home/nix/gc.nix).

  services.openssh.enable = true;
  services.tailscale.enable = true;
  # tailscaled installs its rules via iptables-nft, which live in a different
  # table from the nftables firewall that incus requires. Adding tailscale0 here
  # gets it into the nftables trusted-interfaces set too.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  programs.nix-ld.enable = true; # for claude code / vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  home-manager.sharedModules = [
    "${homeMod}/cli/odu.nix"
    "${homeMod}/cli/atuin.nix"
    "${homeMod}/claude-code"
    # Jump host SOCKS5 (jumphost-nix) — required by pu / juspay-run
    "${homeMod}/work/juspay.nix"
    # Juspay opencode config (juspay-ai) + llm-agents package
    "${homeMod}/work/opencode.nix"
    "${homeMod}/nix/gc.nix"
  ];
}
