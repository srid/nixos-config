# Configuration for the VPS running nginx reverse proxy
{ flake, pkgs, lib, webapps, ... }:

let
  host = "pureintent"; # See host.nix
  webapps = import ./. { inherit flake; system = pkgs.system; };
in
{
  services.tailscale.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = lib.mapAttrs'
      (name: v: lib.nameValuePair v.domain {
        locations."/".proxyPass = "http://${host}:${builtins.toString v.port}";
        enableACME = true;
        addSSL = true;
      })
      webapps;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "srid@srid.ca";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 22 ];
}
