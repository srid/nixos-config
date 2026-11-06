# Grafana for odu's metrics, tailnet-only.
#
# The URL opens straight onto the `odu cache` dashboard: anonymous access is
# Viewer, no login, and the provisioned dashboard is the org's home. The only
# datasource is the in-cluster Prometheus Service. `tailscale.funnel` is
# deliberately absent, so this is Tailscale Serve on the tailnet, like odu's
# internal services.
{ config, lib, pkgs, ... }:
let
  namespace = "grafana-k3s";
  port = 3000;
  labels = { app = "grafana"; };
  image = "busybox:1.36.1@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662";
  app = config.k8s.apps.grafana;
  grafana = pkgs.grafana;
  # Grafana 13 ships datasources as plugins; the Prometheus one is not in the
  # core bundle, so it is mounted into the plugin path from the store.
  prometheusPlugin = pkgs.grafanaPlugins.prometheus;
  dashboard = builtins.readFile ./odu-cache.json;
  datasources = ''
    apiVersion: 1
    datasources:
      - name: Prometheus
        uid: prometheus
        type: prometheus
        access: proxy
        url: http://prometheus.prometheus-k3s.svc.cluster.local:80
        isDefault: true
        editable: false
  '';
  dashboardProvider = ''
    apiVersion: 1
    providers:
      - name: odu
        orgId: 1
        folder: ""
        type: file
        disableDeletion: false
        updateIntervalSeconds: 60
        allowUiUpdates: false
        options:
          path: /etc/grafana/provisioning/dashboards
          foldersFromFilesStructure: false
  '';
  dashboardPath = "/etc/grafana/provisioning/dashboards/odu-cache.json";
in
{
  imports = [ ../../modules ];

  k8s.apps.grafana = {
    inherit namespace image;
    home = "/data";
    packages = [ grafana ];
    hardening.enable = true;
    # The Grafana binary and its public assets live in the host store.
    nix.enable = true;
    network = {
      allowDNS = true;
      egress = [
        {
          to = [{
            namespaceSelector.matchLabels."kubernetes.io/metadata.name" = "prometheus-k3s";
          }];
          ports = [{ protocol = "TCP"; port = 9090; }];
        }
      ];
    };
    tailscale = {
      enable = true;
      hostname = "grafana-k3s";
      podPort = port;
    };
    env = [
      { name = "GF_PATHS_HOME"; value = "${grafana}/share/grafana"; }
      { name = "GF_PATHS_DATA"; value = "/data"; }
      { name = "GF_PATHS_LOGS"; value = "/data/log"; }
      { name = "GF_PATHS_PLUGINS"; value = "/data/plugins"; }
      { name = "GF_PATHS_PROVISIONING"; value = "/etc/grafana/provisioning"; }
      { name = "GF_SERVER_HTTP_ADDR"; value = "0.0.0.0"; }
      { name = "GF_SERVER_HTTP_PORT"; value = toString port; }
      { name = "GF_SERVER_ROOT_URL"; value = "https://grafana-k3s.rooster-blues.ts.net/"; }
      # Anonymous Viewer: the URL opens on the home dashboard without a login.
      { name = "GF_AUTH_ANONYMOUS_ENABLED"; value = "true"; }
      { name = "GF_AUTH_ANONYMOUS_ORG_NAME"; value = "Main Org."; }
      { name = "GF_AUTH_ANONYMOUS_ORG_ROLE"; value = "Viewer"; }
      { name = "GF_AUTH_BASIC_ENABLED"; value = "false"; }
      { name = "GF_AUTH_DISABLE_LOGIN_FORM"; value = "true"; }
      { name = "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH"; value = dashboardPath; }
      # No phone-home: this pod has no public egress.
      { name = "GF_ANALYTICS_REPORTING_ENABLED"; value = "false"; }
      { name = "GF_ANALYTICS_CHECK_FOR_UPDATES"; value = "false"; }
      { name = "GF_ANALYTICS_CHECK_FOR_PLUGIN_UPDATES"; value = "false"; }
      { name = "GF_NEWS_NEWS_FEED_ENABLED"; value = "false"; }
      { name = "GF_USERS_ALLOW_SIGN_UP"; value = "false"; }
    ];
    volumeMounts = [
      { name = "data"; mountPath = "/data"; }
      { name = "plugin-prometheus"; mountPath = "/data/plugins/prometheus"; readOnly = true; }
      { name = "datasources"; mountPath = "/etc/grafana/provisioning/datasources"; readOnly = true; }
      { name = "dashboards"; mountPath = "/etc/grafana/provisioning/dashboards"; readOnly = true; }
    ];
    volumes = [
      { name = "data"; persistentVolumeClaim.claimName = "grafana-data"; }
      { name = "plugin-prometheus"; hostPath = { path = "${prometheusPlugin}"; type = "Directory"; }; }
      { name = "datasources"; configMap.name = "grafana-datasources"; }
      { name = "dashboards"; configMap.name = "grafana-dashboards"; }
    ];
  };

  services.k3s.manifests.grafana.content = [
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
      metadata = { inherit namespace; name = "grafana-data"; };
      spec = {
        accessModes = [ "ReadWriteOnce" ];
        storageClassName = "local-path";
        resources.requests.storage = "1Gi";
      };
    }

    {
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = { inherit namespace; name = "grafana-datasources"; labels = labels; };
      data."datasources.yaml" = datasources;
    }

    {
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = { inherit namespace; name = "grafana-dashboards"; labels = labels; };
      data = {
        "provider.yaml" = dashboardProvider;
        "odu-cache.json" = dashboard;
      };
    }

    {
      apiVersion = "apps/v1";
      kind = "Deployment";
      metadata = { inherit namespace; name = "grafana"; labels = labels; };
      spec = {
        replicas = 1;
        # Grafana's SQLite is single-writer.
        strategy.type = "Recreate";
        selector.matchLabels = labels;
        template = {
          metadata.labels = labels;
          spec = {
            inherit (app) automountServiceAccountToken securityContext volumes;
            containers = [
              {
                name = "grafana";
                inherit image;
                securityContext = app.containerSecurityContext;
                command = [ "${grafana}/bin/grafana" "server" "--homepath" "${grafana}/share/grafana" ];
                inherit (app) env volumeMounts;
                ports = [{ name = "http"; containerPort = port; }];
                readinessProbe = {
                  httpGet = { path = "/api/health"; port = "http"; };
                  initialDelaySeconds = 5;
                  periodSeconds = 10;
                };
                livenessProbe = {
                  httpGet = { path = "/api/health"; port = "http"; };
                  initialDelaySeconds = 30;
                  periodSeconds = 30;
                  timeoutSeconds = 5;
                };
                resources = {
                  requests = { memory = "128Mi"; cpu = "50m"; };
                  limits = { memory = "512Mi"; };
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
      metadata = { inherit namespace; name = "grafana"; labels = labels; };
      spec = {
        selector = labels;
        ports = [{ name = "http"; port = 80; targetPort = "http"; }];
      };
    }
  ];
}
