{ flake, config, ... }:

let
  inherit (flake.inputs) self;
  domain = "pad.srid.ca";
  port = 9112;
in
{
  age.secrets."hedgedoc.env" = {
    file = self + /secrets/hedgedoc.env.age;
    owner = "hedgedoc";
  };
  services.hedgedoc = {
    enable = true;

    environmentFile = config.age.secrets."hedgedoc.env".path;

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
