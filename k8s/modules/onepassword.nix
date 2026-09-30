# Apps map Kubernetes Secret keys to 1Password item/field references.
# This module owns the operator and bootstrap token; apps never receive the token.
{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  apps = lib.filterAttrs (_: app: app.onepassword != { }) config.k8s.apps;
  namespace = "external-secrets";
  store = "onepassword";
  # Single-node K3s API: permit only its service and current node endpoint.
  apiEndpoints = [
    { cidr = "10.43.0.1/32"; port = 443; }
    { cidr = "192.168.2.45/32"; port = 6443; }
  ];
  values = {
    # Only pull secrets. No write-back controllers or admission webhook needed.
    processClusterExternalSecret = false;
    processPushSecret = false;
    processClusterPushSecret = false;
    processClusterGenerator = false;
    webhook.create = false;
    certController.create = false;
    crds.conversion.enabled = false;
    networkPolicy = {
      enabled = true;
      ingress = [ ];
      egress = [
        {
          to = [{
            namespaceSelector.matchLabels."kubernetes.io/metadata.name" = "kube-system";
            podSelector.matchLabels."k8s-app" = "kube-dns";
          }];
          ports = [{ protocol = "UDP"; port = 53; } { protocol = "TCP"; port = 53; }];
        }
        {
          to = [{
            ipBlock = {
              cidr = "0.0.0.0/0";
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
          ports = [{ protocol = "TCP"; port = 443; }];
        }
      ] ++ map
        (endpoint: {
          to = [{ ipBlock.cidr = endpoint.cidr; }];
          ports = [{ protocol = "TCP"; inherit (endpoint) port; }];
        })
        apiEndpoints;
    };
  };
in
{
  options.k8s.apps = mkOption {
    type = types.attrsOf (types.submodule ({ config, ... }: {
      # Secret name -> key -> item/field. Values here are references, never secrets.
      options.onepassword = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = { };
      };
      config.manifests = lib.mapAttrsToList
        (name: fields: {
          apiVersion = "external-secrets.io/v1";
          kind = "ExternalSecret";
          metadata = { inherit (config) namespace; inherit name; };
          spec = {
            # Stay within service-account quotas. Rotation also needs a pod restart.
            refreshInterval = "1h";
            secretStoreRef = { name = store; kind = "ClusterSecretStore"; };
            target = { inherit name; creationPolicy = "Owner"; deletionPolicy = "Retain"; };
            data = lib.mapAttrsToList
              (secretKey: key: {
                inherit secretKey;
                remoteRef = { inherit key; };
              })
              fields;
          };
        })
        config.onepassword;
    }));
  };

  config = lib.mkIf (apps != { }) {
    age.secrets."onepassword-token.json".file = ../../secrets/onepassword-token.json.age;
    services.k3s.manifests = {
      onepassword-token.source = config.age.secrets."onepassword-token.json".path;
      external-secrets.content = {
        apiVersion = "helm.cattle.io/v1";
        kind = "HelmChart";
        metadata = { name = "external-secrets"; namespace = "kube-system"; };
        spec = {
          repo = "https://charts.external-secrets.io";
          chart = "external-secrets";
          version = "2.11.0";
          targetNamespace = namespace;
          createNamespace = true;
          valuesContent = builtins.toJSON values;
        };
      };
      onepassword.content = [
        {
          apiVersion = "networking.k8s.io/v1";
          kind = "NetworkPolicy";
          metadata = { inherit namespace; name = "default-deny"; };
          spec = { podSelector = { }; policyTypes = [ "Ingress" "Egress" ]; };
        }
        {
          apiVersion = "external-secrets.io/v1";
          kind = "ClusterSecretStore";
          metadata.name = store;
          spec = {
            refreshInterval = 3600;
            # Only explicitly participating app namespaces may use this vault.
            conditions = [{ namespaces = lib.unique (map (app: app.namespace) (lib.attrValues apps)); }];
            provider.onepasswordSDK = {
              vault = "Kubernetes";
              auth.serviceAccountSecretRef = {
                inherit namespace;
                name = "onepassword-token";
                key = "token";
              };
            };
          };
        }
      ];
    };
  };
}
