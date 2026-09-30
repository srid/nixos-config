# Single-node learning cluster. Inspect it with `sudo k3s kubectl get pods -A`.
# K3s includes local-path storage; Tailscale exposes the olai Service.
{ ... }:
{
  imports = [ ./k3s-olai ];

  # Allow the API server and pod-to-host traffic (including kubelet metrics).
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = [ "cni0" "flannel.1" ];

  services.k3s = {
    enable = true;
    role = "server";

    # K3s's Helm controller installs the operator. Create its operator-oauth
    # Secret separately; see k3s-olai/README.md for the one-time tailnet setup.
    manifests.tailscale-operator.content = {
      apiVersion = "helm.cattle.io/v1";
      kind = "HelmChart";
      metadata = { name = "tailscale-operator"; namespace = "kube-system"; };
      spec = {
        repo = "https://pkgs.tailscale.com/helmcharts";
        chart = "tailscale-operator";
        version = "1.102.4";
        targetNamespace = "tailscale";
        createNamespace = true;
        set."operatorConfig.hostname" = "naiveintent-k3s-operator";
      };
    };
  };
}
