# Single-node learning cluster, enabled by the host importing this module.
{ ... }:
{
  imports = [
    ./network.nix
    ./tailscale.nix
    ./apps/olai
  ];

  services.k3s = {
    enable = true;
    role = "server";
  };
}
