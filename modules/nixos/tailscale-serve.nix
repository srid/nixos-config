# The node's own tailnet HTTPS, pointed at a local HTTP service.
#
# A consumer declares what it has — a name and a loopback port — and this module
# owns everything around it: the oneshot that asserts the proxy after
# tailscaled's backend is up, the retry that survives startup and offline
# periods, and the ExecStop that removes it. It knows no host, domain, origin or
# service: `tailscale serve` terminates TLS with the node's own tailnet
# certificate and injects `Tailscale-User-*` headers, so a service behind it
# needs only to name its origin (`OLAI_ALLOWED_ORIGINS` and friends).
#
#   tailscaleServe.olai.port = 7714;
#
# Tailnet policy is the access control; this is not Funnel, so nothing is
# published to the public internet.
{ config, lib, pkgs, ... }:

let
  cfg = config.tailscaleServe;

  inherit (lib) mkIf mkOption types;

  tailscale = lib.getExe pkgs.tailscale;
in
{
  options.tailscaleServe = mkOption {
    default = { };
    description = ''
      Tailnet HTTPS proxies to local HTTP services, one systemd oneshot per
      entry (`tailscale serve --https=<port> http://127.0.0.1:<local port>`).
    '';
    type = types.attrsOf (types.submodule {
      options = {
        port = mkOption {
          type = types.port;
          description = "Local HTTP port on 127.0.0.1 to proxy to";
        };
        httpsPort = mkOption {
          type = types.port;
          default = 443;
          description = "HTTPS port on the tailnet; 443 is what a bare node name uses";
        };
      };
    });
  };

  config = mkIf (cfg != { }) {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscaleServe needs services.tailscale.enable.";
      }
    ];

    systemd.services = lib.mapAttrs'
      (name: serve: lib.nameValuePair "tailscale-serve-${name}" {
        description = "Serve ${name} over tailnet HTTPS";
        after = [ "tailscaled.service" "tailscaled-set.service" ];
        wants = [ "tailscaled.service" ];
        wantedBy = [ "multi-user.target" ];
        # tailscaled can be active before its backend reaches Running. Keep
        # retrying through startup/offline periods instead of failing until
        # reboot.
        startLimitIntervalSec = 0;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "5s";
          # `--bg` keeps the config in tailscaled's own state, so this unit only
          # re-asserts it after a `tailscale up` or a backend restart.
          ExecStart = "${tailscale} serve --bg --https=${toString serve.httpsPort} http://127.0.0.1:${toString serve.port}";
          ExecStop = "${tailscale} serve --https=${toString serve.httpsPort} off";
        };
      })
      cfg;
  };
}
