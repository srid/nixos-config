# Enable tailscale.enable to expose an app's Service over tailnet HTTPS.
# Requires the shared operator from ../tailscale.nix and tailnet HTTPS enabled.
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
    # Funnel publishes the Ingress on the public internet, not only the tailnet,
    # so the app must authenticate on its own. The tailnet policy has to grant
    # the `funnel` node attribute to tag:k8s (the operator's proxies).
    funnel = lib.mkEnableOption "Tailscale Funnel (public HTTPS) for the Ingress";
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
    # Keep the backend Service internal; this Ingress owns Tailscale exposure.
    # Tailnet policy must allow TCP 443 to the proxy.
    manifests = [{
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = { inherit (config) namespace; inherit name; }
        // lib.optionalAttrs cfg.funnel { annotations."tailscale.com/funnel" = "true"; };
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
