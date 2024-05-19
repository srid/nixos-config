{ config, pkgs, lib, ... }:

let
  domain = "pad.srid.ca";
  port = 9112;
in
{
  services.hedgedoc = {
    enable = true;

    # GitHub secrets set in colmena (see flake.nix)
    environmentFile = "/run/keys/hedgedoc.env";

    settings = {
      # URL config
      inherit domain port;
      protocolUseSSL = true;
      urlAddPort = false;
      allowOrigin = [ "localhost" ];

      # Accept GitHub users only.
      # NOTE: Fine-grained access (eg: whitelist of users) not possible until
      # HedgeDoc 2.0
      email = false;
      allowAnonymous = false;
    };
  };

  services.nginx = {
    virtualHosts.${domain} = {
      enableACME = true;
      addSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString port}";
        proxyWebsockets = true;
      };
    };
  };
}
