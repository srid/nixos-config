# https://wiki.nixos.org/wiki/Incus
{ flake, ... }:
let
  lxdProvider = "incus";
  networkName = "${lxdProvider}br0";

  # Problems? 
  # 1. Disable the service
  # 2. Reset with: `sudo rm -rf /var/lib/lx* /var/lib/incus/`
  # 3. Reboot
  # 4. Then re-enable service
  preseedConfig = {
    networks = [
      {
        name = networkName;
        type = "bridge";
        config = {
          "ipv4.address" = "10.0.100.1/24";
          "ipv4.nat" = "true";
        };
      }
    ];
    profiles = [
      {
        name = "default";
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
        };
      }
    ];
    storage_pools = [
      {
        name = "default";
        driver = "dir";
        config = {
          source = "/var/lib/${lxdProvider}/storage-pools/default";
        };
      }
    ];
  };
in
{
  virtualisation.${lxdProvider} = {
    enable = true;
    preseed = preseedConfig;
  };

  users.users.${flake.config.me.username} = {
    extraGroups = [ lxdProvider ];
  };

  networking.nftables.enable = true;

  # networking.firewall.enable = false;
  networking.firewall.trustedInterfaces = [ networkName ];
}
