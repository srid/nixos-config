# Container-side essentials for incus-pet — the OTHER half of this tree.
#
# default.nix configures the incus daemon ON THE HOST (bridge, UI, etc).
# THIS module is imported INSIDE each containerized app's nixosConfiguration,
# alongside the app's own nixosModules.incus. It declares the contract
# options that every app's incus module sets, and the boring NixOS-inside-
# a-container plumbing (sshd, base packages, firewall).
#
# The incus-pet CLI's marshaling flake imports this file directly by store
# path — no flake-input dance — so this file stays as a plain NixOS module.
{ config, lib, pkgs, modulesPath, ... }:
let
  cfg = config.incus.container;
in
{
  # `lxc-container.nix` is the upstream nixpkgs module that turns a
  # NixOS evaluation into something that boots as an LXC/incus container
  # — skips the boot loader, sets `fileSystems` defaults, wires up
  # systemd-networkd with eth0 DHCP, and trims a pile of host-only
  # services. The official `images:nixos/25.11` image imports the same
  # module via its /etc/nixos/configuration.nix; we re-import here so
  # `nixos-rebuild --target-host` doesn't lose any of that when it
  # replaces /etc/nixos at switch time.
  imports = [ "${modulesPath}/virtualisation/lxc-container.nix" ];

  # The CONVENTION: every containerized service binds 8080 inside its
  # own netns. The host-side incus proxy device translates a unique
  # <listen-ip>:<host-port> to <container>:8080 at deploy time. App
  # modules just hardcode `services.<app>.port = 8080;` — no shared
  # option, no forward reference, no coupling between an app's flake
  # and this tree at evaluation time.
  options.incus.container = {
    enable = lib.mkEnableOption "incus-pet container essentials";

    hostname = lib.mkOption {
      type = lib.types.str;
      description = ''
        Container hostname. Each app's nixosModules.incus sets this
        with mkDefault; the operator can override per deploy if they
        want a different name than the app's default.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.hostName = cfg.hostname;

    # NixOS-inside-a-container essentials. The community NixOS incus
    # image ships with neither sshd nor flakes; the incus-pet CLI does
    # a one-time bootstrap via `incus exec` to push the operator pubkey
    # and apply a temporary config that enables both. From the FIRST
    # `nixos-rebuild --target-host` onwards, the deployed config (this
    # module) carries those settings forward.
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # The hardcoded service port — opening it here too is cheap
    # insurance against a mis-authored app module forgetting to.
    networking.firewall.allowedTCPPorts = [ 8080 ];

    environment.systemPackages = with pkgs; [
      git
      vim
      curl
      htop
    ];

    # Workaround the same dbus-broker reload stall pureintent hits
    # (NixOS#... — the broker has long-lived clients holding the bus,
    # the reload step times out, switch-to-configuration exits 4 even
    # though activation succeeded). Skip reload/restart at activation
    # time; bus policy changes land on next container restart.
    systemd.services.dbus-broker.reloadIfChanged = lib.mkForce false;
    systemd.services.dbus-broker.restartIfChanged = lib.mkForce false;
  };
}
