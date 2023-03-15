{ keyName, domain }:

{ pkgs, lib, config, flake, ... }:
{
  imports = [
    flake.inputs.nix-serve-ng.nixosModules.default
  ];

  # Cache server
  age.secrets.${keyName}.file = ../secrets/${keyName}.age;
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.${keyName}.path;
  };
  nix.settings.allowed-users = [ "nix-serve" ];
  nix.settings.trusted-users = [ "nix-serve" ];

  # Web servr
  services.nginx = {
    virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:${toString config.services.nix-serve.port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
