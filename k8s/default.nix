# Single-node learning cluster, enabled by the host importing this module.
{ ... }:
{
  imports = [
    ./tailscale.nix
    ./apps/olai
  ];

  # Allow the API server and pod-to-host traffic (including kubelet metrics).
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = [ "cni0" "flannel.1" ];

  services.k3s = {
    enable = true;
    role = "server";
  };
}
