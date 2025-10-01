{ config, lib, pkgs, flake, ... }:

let
  inherit (flake.inputs) self;
  cfg = config.services.nix-serve-ng-cf;
in
{
  options.services.nix-serve-ng-cf = {
    enable = lib.mkEnableOption "nix-serve-ng with Cloudflare tunnel";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Port for nix-serve-ng to listen on";
    };

    secretKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "nix-serve-cache-key.pem";
      description = "Path relative to secrets directory for the cache signing key";
      example = "nix-serve-cache-key.pem";
    };

    cloudflare = {
      tunnelId = lib.mkOption {
        type = lib.types.str;
        description = "Cloudflare tunnel ID";
      };

      credentialsPath = lib.mkOption {
        type = lib.types.str;
        default = "cloudflared-nix-cache.json";
        description = "Path relative to secrets directory for Cloudflare tunnel credentials";
        example = "cloudflared-nix-cache.json";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "Domain name for the Nix cache";
        example = "cache.example.com";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."${cfg.secretKeyPath}" = {
      file = self + /secrets/${cfg.secretKeyPath}.age;
      mode = "0400";
    };

    age.secrets."${cfg.cloudflare.credentialsPath}" = {
      file = self + /secrets/${cfg.cloudflare.credentialsPath}.age;
      mode = "0400";
    };

    services.nix-serve = {
      enable = true;
      port = cfg.port;
      secretKeyFile = config.age.secrets."${cfg.secretKeyPath}".path;
      package = pkgs.nix-serve-ng;
    };

    services.cloudflared = {
      enable = true;
      tunnels = {
        "${cfg.cloudflare.tunnelId}" = {
          credentialsFile = config.age.secrets."${cfg.cloudflare.credentialsPath}".path;
          default = "http_status:404";
          ingress = {
            "${cfg.cloudflare.domain}" = "http://localhost:${toString cfg.port}";
          };
        };
      };
    };
  };
}
