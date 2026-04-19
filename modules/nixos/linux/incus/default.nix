# See ./README.md for usage and troubleshooting.
{ flake, ... }:
let
  networkName = "incusbr0";

  preseedConfig = {
    networks = [
      {
        name = networkName;
        type = "bridge";
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
          source = "/var/lib/incus/storage-pools/default";
        };
      }
    ];
  };
in
{
  virtualisation.incus = {
    enable = true;
    ui.enable = true;
    preseed = preseedConfig;
  };

  users.users.${flake.config.me.username} = {
    extraGroups = [ "incus" "incus-admin" ];
  };

  networking.nftables.enable = true;

  networking.firewall.trustedInterfaces = [ networkName ];
}
