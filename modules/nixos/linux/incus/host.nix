# Incus daemon on the container host. See ./README.md.
#
# Deliberately minimal compared to what it replaced (incus-pet): no web
# UI, no incus/incus-admin groups (operate via `sudo incus`), no proxy
# devices. Containers join the tailnet themselves and publish services
# with `tailscale serve`, so no service traffic ever transits the host.
{ ... }:
let
  networkName = "incusbr0";
  # Deploy channel: `just <name> deploy` copies the container's system
  # closure here as a binary cache; the container imports it via the
  # read-only `nix-cache` disk device below. No SSH anywhere.
  cacheDir = "/var/cache/incus-nix";
in
{
  virtualisation.incus = {
    enable = true;
    preseed = {
      networks = [
        {
          name = networkName;
          type = "bridge";
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config.source = "/var/lib/incus/storage-pools/default";
        }
      ];
      profiles = [
        {
          name = "default";
          config = {
            # NixOS-in-a-container runs its own systemd/firewall; without
            # nesting its firewall unit fails (lxc/incus#526).
            "security.nesting" = "true";
          };
          devices = {
            eth0 = {
              name = "eth0";
              network = networkName;
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
            # tailscaled inside the container needs a tun device.
            tun = {
              type = "unix-char";
              source = "/dev/net/tun";
              path = "/dev/net/tun";
            };
            nix-cache = {
              type = "disk";
              source = cacheDir;
              path = "/host-nix-cache";
              readonly = "true";
            };
          };
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [ "d ${cacheDir} 0755 root root -" ];

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ networkName ];
}
