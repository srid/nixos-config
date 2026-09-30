# Tailnet HTTPS ingress for an app's existing Service.
# Enable with k8s.apps.<name>.tailscale.enable; merge the app's `manifests`
# into its K3s manifest. This module needs the shared operator in ../tailscale.nix.
# The app owns the backend Service; do not also expose that Service via Tailscale.
# HTTPS certificates must be enabled in the tailnet, with TCP 443 allowed by policy.
{ config, lib, name, ... }:
let
  cfg = config.tailscale;
  inherit (lib) mkOption types;
in
{
  options.tailscale = {
    enable = lib.mkEnableOption "Tailscale-managed HTTPS ingress";
    hostname = mkOption {
      type = types.str;
      default = name;
      description = "Short tailnet hostname; the operator appends the tailnet DNS suffix.";
    };
    # Backend Service in the app's namespace; this is its Service port, not a pod port.
    serviceName = mkOption { type = types.str; default = name; };
    servicePort = mkOption { type = types.port; default = 80; };
    # NetworkPolicy matches the destination pod port after Service translation.
    podPort = mkOption { type = types.port; default = cfg.servicePort; };
  };

  config = lib.mkIf cfg.enable {
    network.ingress = [{
      from = [{
        namespaceSelector.matchLabels."kubernetes.io/metadata.name" = "tailscale";
        podSelector.matchLabels = {
          "tailscale.com/managed" = "true";
          "tailscale.com/parent-resource" = name;
          "tailscale.com/parent-resource-ns" = config.namespace;
          "tailscale.com/parent-resource-type" = "ingress";
        };
      }];
      ports = [{ protocol = "TCP"; port = cfg.podPort; }];
    }];
    manifests = [{
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = { inherit (config) namespace; inherit name; };
      spec = {
        ingressClassName = "tailscale";
        # A short name selects the tailnet device; browse its full *.ts.net name.
        # Tailscale provisions the certificate, so no Kubernetes TLS Secret is needed.
        tls = [{ hosts = [ cfg.hostname ]; }];
        defaultBackend.service = {
          name = cfg.serviceName;
          port.number = cfg.servicePort;
        };
      };
    }];
  };
}
