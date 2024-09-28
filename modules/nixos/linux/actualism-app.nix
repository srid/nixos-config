{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };
  # actualism-app (temp host)
  services.nginx = {
    enable = true;
    virtualHosts."www.actualism.app" = {
      enableACME = true;
      # addSSL = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "srid@srid.ca";
  };
  systemd.services.actualism-app = {
    enable = true;
    description = "actualism-app server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart =
        lib.getExe (pkgs.writeShellApplication {
          name = "actualism-app-start";
          text = ''
            cd ${pkgs.actualism-app}/ 
            ${pkgs.actualism-app}/bin/actualism-app
          '';
        });
      Restart = "always";
    };
  };
}
