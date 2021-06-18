{ pkgs, inputs, system, ... }:
let
  emanote = inputs.emanote.outputs.defaultPackage.${system};
in
{
  environment.systemPackages = [ emanote ];

  # Before starting the service, use `protonmail-bridge --cli` and run 'login'
  # to configure.
  systemd.user.services.emanote = {
    description = "Emanote ~/Documents/Notes";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    environment = {
      PORT = "7000";
    };
    serviceConfig = {
      Restart = "always";
      ExecStart = "${emanote}/bin/emanote -C /home/srid/Documents/Notes";
    };
  };
}
