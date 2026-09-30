# Cluster-wide Tailscale operator and agenix credentials.
{ config, flake, ... }:
{
  age.secrets."tailscale-operator-oauth.yaml".file =
    flake.inputs.self + /secrets/tailscale-operator-oauth.yaml.age;

  services.k3s = {
    # A runtime symlink, not a Nix-generated plaintext manifest.
    manifests.tailscale-operator-oauth = {
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
        set."operatorConfig.hostname" = "${config.networking.hostName}-k3s-operator";
      };
    };
  };
}
