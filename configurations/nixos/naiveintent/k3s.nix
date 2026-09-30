# Single-node learning cluster. Inspect it with `sudo k3s kubectl get pods -A`.
# K3s includes Traefik ingress and local-path storage.
{ ... }:
{
  imports = [ ./k3s-olai ];

  # Allow the API server and pod-to-host traffic (including kubelet metrics).
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = [ "cni0" "flannel.1" ];

  services.k3s = {
    enable = true;
    role = "server";
  };
}
