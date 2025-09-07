{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.vira.nixosModules.vira
  ];

  services.vira = {
    enable = true;
    stateDir = "/var/lib/vira";
    hostname = "127.0.0.1"; # Cuz, nginx reverse proxy
    port = 5001;
    https = false; # Cuz, nginx reverse proxy
    basePath = "/vira/"; # Cuz, nginx reverse proxy
    package = inputs.vira.packages.${pkgs.system}.default;

    initialState = {
      repositories = {
        nixos-config = "https://github.com/srid/nixos-config.git";
        haskell-flake = "https://github.com/srid/haskell-flake.git";
        vira = "https://github.com/juspay/vira.git";
      };
    };
  };

  # Configure nginx reverse proxy for vira with SSL
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."pureintent" = {
      forceSSL = true;
      enableACME = false;
      sslCertificate = "/var/lib/acme/pureintent/cert.pem";
      sslCertificateKey = "/var/lib/acme/pureintent/key.pem";
      locations."/vira/" = {
        proxyPass = "http://127.0.0.1:5001/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  # Generate self-signed certificate for nginx
  systemd.services.nginx-self-signed-cert = {
    description = "Generate self-signed certificate for nginx";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    script = ''
      mkdir -p /var/lib/acme/pureintent
      if [ ! -f /var/lib/acme/pureintent/cert.pem ] || [ ! -f /var/lib/acme/pureintent/key.pem ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -keyout /var/lib/acme/pureintent/key.pem -out /var/lib/acme/pureintent/cert.pem -days 365 -nodes -subj "/C=US/ST=Local/L=Local/O=Local/CN=pureintent"
        chmod 600 /var/lib/acme/pureintent/key.pem
        chmod 644 /var/lib/acme/pureintent/cert.pem
        chown -R nginx:nginx /var/lib/acme/pureintent
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };


}
