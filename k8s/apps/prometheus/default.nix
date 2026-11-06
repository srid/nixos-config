# Prometheus scraping odu's /metrics, tailnet-only.
#
# The UI and API are reached over a Tailscale Serve Ingress
# (https://prometheus-k3s.rooster-blues.ts.net) — never the public internet:
# `tailscale.funnel` is deliberately absent. The scrape credential is a metrics
# token minted by odu, delivered to the namespace the same way odu's own
# secrets are (an ExternalSecret for the `odu-prometheus` 1Password item).
{ config, lib, pkgs, ... }:
let
  namespace = "prometheus-k3s";
  port = 9090;
  retention = "30d";
  externalUrl = "https://prometheus-k3s.rooster-blues.ts.net/";
  labels = { app = "prometheus"; };
  image = "busybox:1.36.1@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662";
  app = config.k8s.apps.prometheus;
  prometheus = pkgs.prometheus;
  # The target is the odu Service inside the cluster, never the Funnel: the
  # scrape is cluster-local with the token file, and the Service port 80 maps
  # to the pod's 18440.
  prometheusConfig = ''
    global:
      scrape_interval: 30s
      evaluation_interval: 30s

    scrape_configs:
      - job_name: odu
        scheme: http
        metrics_path: /metrics
        bearer_token_file: /etc/odu-prometheus/token
        static_configs:
          - targets:
              - odu.odu-k3s.svc.cluster.local:80

      # Prometheus itself: the build/runtime metrics that make the UI's
      # metric list useful, and a health target beside odu.
      - job_name: prometheus
        static_configs:
          - targets:
              - localhost:9090
  '';
in
{
  imports = [ ../../modules ./secrets.nix ];

  k8s.apps.prometheus = {
    inherit namespace image;
    home = "/data";
    packages = [ prometheus ];
    hardening.enable = true;
    # The Prometheus binary and its libraries live in the host store; the nix
    # module supplies the read-only /nix/store mount. No Nix use otherwise.
    nix.enable = true;
    network = {
      allowDNS = true;
      egress = [
        {
          to = [{
            namespaceSelector.matchLabels."kubernetes.io/metadata.name" = "odu-k3s";
          }];
          ports = [{ protocol = "TCP"; port = 18440; }];
        }
      ];
    };
    # Serve on the tailnet only — no `funnel = true`, unlike the odu board.
    tailscale = {
      enable = true;
      hostname = "prometheus-k3s";
      podPort = port;
    };
    volumeMounts = [
      { name = "data"; mountPath = "/data"; }
      { name = "config"; mountPath = "/etc/prometheus"; readOnly = true; }
      { name = "odu-prometheus"; mountPath = "/etc/odu-prometheus"; readOnly = true; }
    ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "prometheus-data"; }
      { name = "config"; configMap.name = "prometheus-config"; }
      { name = "odu-prometheus"; secret.secretName = "odu-prometheus"; defaultMode = 288; }
    ];
    # Grafana in its own namespace reads the API; the namespace default-denies.
    manifests = [
      {
        apiVersion = "networking.k8s.io/v1";
        kind = "NetworkPolicy";
        metadata = { inherit namespace; name = "prometheus-allow-grafana"; };
        spec = {
          podSelector.matchLabels = labels;
          policyTypes = [ "Ingress" ];
          ingress = [
            {
              from = [{
                namespaceSelector.matchLabels."kubernetes.io/metadata.name" = "grafana-k3s";
              }];
              ports = [{ protocol = "TCP"; port = port; }];
            }
          ];
        };
      }
    ];
  };

  services.k3s.manifests.prometheus.content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = { name = namespace; };
    }
  ] ++ app.manifests ++ [
    # local-path preserves data, but does not enforce the requested size.
    {
      apiVersion = "v1";
      kind = "PersistentVolumeClaim";
      metadata = { inherit namespace; name = "prometheus-data"; };
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "local-path";
        resources.requests.storage = "2Gi";
      };
    }

    {
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = { inherit namespace; name = "prometheus-config"; labels = labels; };
      data."prometheus.yml" = prometheusConfig;
    }

    {
      apiVersion = "apps/v1";
      kind = "Deployment";
      metadata = { inherit namespace; name = "prometheus"; labels = labels; };
      spec = {
        replicas = 1;
        # The TSDB is single-writer.
        strategy.type = "Recreate";
        selector.matchLabels = labels;
        template = {
          metadata.labels = labels;
          spec = {
            inherit (app) automountServiceAccountToken securityContext volumes;
            containers = [
              {
                name = "prometheus";
                inherit image;
                securityContext = app.containerSecurityContext;
                command = [
                  "${prometheus}/bin/prometheus"
                  "--config.file=/etc/prometheus/prometheus.yml"
                  "--storage.tsdb.path=/data"
                  "--storage.tsdb.retention.time=${retention}"
                  "--web.listen-address=0.0.0.0:${toString port}"
                  # The pages and API build their URLs from this origin, and
                  # the route prefix keeps them rooted at `/` behind the
                  # Tailscale Ingress. `/graph` redirects to `/query` in
                  # Prometheus 3; that redirect is correct.
                  "--web.external-url=${externalUrl}"
                  "--web.route-prefix=/"
                ];
                inherit (app) env volumeMounts;
                ports = [{ name = "http"; containerPort = port; }];
                readinessProbe = {
                  httpGet = { path = "/-/ready"; port = "http"; };
                  initialDelaySeconds = 3;
                  periodSeconds = 10;
                };
                livenessProbe = {
                  httpGet = { path = "/-/healthy"; port = "http"; };
                  initialDelaySeconds = 30;
                  periodSeconds = 30;
                };
                resources = {
                  requests = { memory = "128Mi"; cpu = "50m"; };
                  limits = { memory = "1Gi"; };
                };
              }
            ];
          };
        };
      };
    }

    {
      apiVersion = "v1";
      kind = "Service";
      metadata = { inherit namespace; name = "prometheus"; labels = labels; };
      spec = {
        selector = labels;
        ports = [{ name = "http"; port = 80; targetPort = "http"; }];
      };
    }
  ];
}
