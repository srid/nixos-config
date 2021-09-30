{ pkgs, inputs, system, ... }:
let
  emanote = inputs.emanote.outputs.defaultPackage.${system};
in
{
  systemd.user.services.emanote = {
    description = "Emanote ~/Documents/Notes";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    environment = {
      PORT = "7000";
    };
    serviceConfig = {
      Restart = "always";
      ExecStart = "${emanote}/bin/emanote -L /home/srid/Documents/Notes";
    };
  };
}
