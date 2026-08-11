# Container-side base, imported by each configurations/nixos/<container>
# entry. See ./README.md.
#
# No sshd: deploys arrive over `incus exec` from the host (see ./mod.just)
# and a shell is `just incus shell <name>`. Services bind 127.0.0.1 and
# are published with `tailscale serve`, so the container's own tailnet
# node is the only way in.
{ lib, modulesPath, ... }:
{
  imports = [
    # Upstream module that makes a NixOS eval bootable as an LXC/incus
    # container: no bootloader, eth0 DHCP via systemd-networkd, host-only
    # services trimmed. The images:nixos image imports the same module.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  options.incus = {
    servePort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = ''
        Loopback port published on the tailnet as
        https://<hostname>.<tailnet>.ts.net. Read by mod.just's
        `tailscale` recipe, which runs `tailscale serve --bg` once —
        the serve config then persists in /var/lib/tailscale.
      '';
    };
  };

  config = {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    # Each deploy copies a fresh closure into the container's store; let
    # old generations go on their own.
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    # dbus-broker's activation-time reload stalls when long-lived clients
    # hold the bus (switch-to-configuration exits 4 even though activation
    # succeeded). Skip it; bus policy changes land on container restart.
    systemd.services.dbus-broker.reloadIfChanged = lib.mkForce false;
    systemd.services.dbus-broker.restartIfChanged = lib.mkForce false;
  };
}
