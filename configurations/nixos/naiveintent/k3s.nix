# Single-node learning cluster. Inspect it with `sudo k3s kubectl get pods -A`.
# K3s includes local-path storage; Tailscale exposes the olai Service.
{ config, flake, lib, ... }:
let
  oauthFile = "${flake.inputs.self}/secrets/tailscale-operator-oauth.yaml.age";
  hasOAuth = builtins.pathExists oauthFile;
in
{
  imports = [ ./k3s-olai ];

  # Bootstrap without credentials; the operator waits until this is supplied.
  warnings = lib.optional (!hasOAuth)
    "K3s Tailscale: add secrets/tailscale-operator-oauth.yaml.age (see k3s-olai/README.md).";
  age.secrets = lib.optionalAttrs hasOAuth {
    "tailscale-operator-oauth.yaml".file = oauthFile;
  };

  # Allow the API server and pod-to-host traffic (including kubelet metrics).
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = [ "cni0" "flannel.1" ];

  services.k3s = {
    enable = true;
    role = "server";

    # A runtime symlink, not a Nix-generated plaintext manifest.
    manifests.tailscale-operator-oauth = lib.mkIf hasOAuth {
      source = config.age.secrets."tailscale-operator-oauth.yaml".path;
    };

    # K3s's Helm controller installs the operator; agenix supplies its Secret.
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
