{ keyName, domain }:

{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    inputs.nix-serve-ng.nixosModules.default
  ];

  age.secrets.${keyName}.file = ../secrets/${keyName}.age;
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.${keyName}.path;
  };
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
