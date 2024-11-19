# Configuration for the host on which all webapps will run.
{ flake, pkgs, lib, ... }:

let
  webapps = import ./. { inherit flake; system = pkgs.system; };
in
{
  # Run each web app as a systemd service decided inside a container.
  containers = lib.mapAttrs
    (name: v: {
      autoStart = true;
      config = {
        systemd.services.${name} = {
          description = name;
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe v.package}";
            Restart = "always";
          };
        };
      };
    })
    webapps;
}
