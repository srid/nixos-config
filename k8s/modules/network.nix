# App namespaces deny ingress and egress by default, including unlabelled pods.
# Explicit allow rules select app=<name>; keep that label on the app's pod template.
# NetworkPolicies are additive: another allow policy can widen access. This is for
# workload namespaces, not kube-system/tailscale, whose controllers need API access.
# K3s's kube-router enforces these rules. ../network.nix also guards host INPUT;
# the local-node exception makes NetworkPolicy alone an insufficient host boundary.
{ config, lib, name, ... }:
let
  cfg = config.network;
  inherit (lib) mkOption types;
  rules = mkOption { type = types.listOf types.attrs; default = [ ]; };
in
{
  options.network = {
    allowDNS = lib.mkEnableOption "queries to cluster CoreDNS";
    # Public IPv4 only; IPv6 remains denied on this single-stack cluster.
    # Empty by default. Apps opt into ports they actually use (e.g. [ 80 443 ]).
    publicTCPPorts = mkOption { type = types.listOf types.port; default = [ ]; };
    ingress = rules;
    egress = rules;
  };

  config.manifests = [
    {
      apiVersion = "networking.k8s.io/v1";
      kind = "NetworkPolicy";
      metadata = { inherit (config) namespace; name = "${name}-default-deny"; };
      spec = {
        podSelector = { };
        policyTypes = [ "Ingress" "Egress" ];
      };
    }
    {
      apiVersion = "networking.k8s.io/v1";
      kind = "NetworkPolicy";
      metadata = { inherit (config) namespace; name = "${name}-allow"; };
      spec = {
        podSelector.matchLabels.app = name;
        policyTypes = [ "Ingress" "Egress" ];
        ingress = cfg.ingress;
        egress = cfg.egress
          ++ lib.optional cfg.allowDNS {
          to = [{
            namespaceSelector.matchLabels."kubernetes.io/metadata.name" = "kube-system";
            podSelector.matchLabels."k8s-app" = "kube-dns";
          }];
          ports = [{ protocol = "UDP"; port = 53; } { protocol = "TCP"; port = 53; }];
        }
          ++ lib.optional (cfg.publicTCPPorts != [ ]) {
          to = [{
            ipBlock = {
              cidr = "0.0.0.0/0";
              # Exclude private, tailnet/CGNAT, loopback, link-local, documentation,
              # benchmarking, multicast and reserved ranges. This also covers the
              # cluster Pod/Service CIDRs and Incus bridge with K3s's defaults.
              except = [
                "0.0.0.0/8"
                "10.0.0.0/8"
                "100.64.0.0/10"
                "127.0.0.0/8"
                "169.254.0.0/16"
                "172.16.0.0/12"
                "192.0.0.0/24"
                "192.0.2.0/24"
                "192.168.0.0/16"
                "198.18.0.0/15"
                "198.51.100.0/24"
                "203.0.113.0/24"
                "224.0.0.0/4"
                "240.0.0.0/4"
              ];
            };
          }];
          ports = map (port: { protocol = "TCP"; inherit port; }) cfg.publicTCPPorts;
        };
      };
    }
  ];
}
