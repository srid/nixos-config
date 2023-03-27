{ flake, ... }:

# TODO:
# - Build agents (SSH slave)
#    - NixOS slave: container separation?
#    - macOS slave (later)
{
  services.nginx = {
    virtualHosts.${flake.config.jenkins-nix-ci.domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:${toString flake.config.jenkins-nix-ci.port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
