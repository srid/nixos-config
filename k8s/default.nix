# Single-node learning cluster. A host imports this module for the cluster
# itself, then imports the apps it runs (`./apps/<name>`); each host is its
# own independent cluster. Apps are not listed here on purpose.
{ config, lib, ... }:
{
  imports = [
    ./network.nix
    ./tailscale.nix
  ];

  options.k8s.nodeIP = lib.mkOption {
    type = lib.types.str;
    description = ''
      The host's LAN address that K3s advertises as the node IP. Pinned so a
      second interface (Wi-Fi beside Ethernet) cannot move it between boots;
      NetworkPolicies that allow the API endpoint are derived from it. Give
      the host a DHCP reservation for this address.
    '';
  };

  config.services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [ "--node-ip=${config.k8s.nodeIP}" ];
  };
}
