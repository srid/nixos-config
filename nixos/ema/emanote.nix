{ pkgs, inputs, system, flake, ... }:
let
  emanote = inputs.emanote.outputs.defaultPackage.${system};
in
{
  # Global service, rather than user service, as the latter doesn't work in NixOS-WSL
  systemd.services.emanote = {
    description = "Emanote ~/Documents/Notes";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    environment = {
      PORT = "7000";
    };
    serviceConfig = {
      User = flake.config.people.myself;
      Restart = "always";
      ExecStart = "${emanote}/bin/emanote -L /home/${flake.config.people.myself}/Documents/Notes";
    };
  };
}
