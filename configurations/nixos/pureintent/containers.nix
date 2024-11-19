# TODO(refactor): decompose
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  actualism-app = inputs.actualism-app.packages.${pkgs.system}.default;
  app-port = 3000;
  app-domain = "actualism.app";
in
{
  containers.actualism-app = {
    autoStart = true;
    config = { lib, ... }: {
      systemd.services.actualism-app = {
        description = "actualism-app";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe actualism-app}";
          Restart = "always";
        };
      };
    };
  };

  # TODO: cloudflare tunnels
  services.nginx = {
    enable = true;
    virtualHosts.${app-domain} = {
      locations."/".proxyPass = "http://localhost:${builtins.toString app-port}";
    };
  };
}
