# TODO(refactor): decompose
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  actualism-app = inputs.actualism-app.packages.${pkgs.system}.default;
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
}
