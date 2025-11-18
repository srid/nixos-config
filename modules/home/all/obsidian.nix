{ flake, pkgs, lib, config, ... }:

let
  inherit (flake) inputs;
  imakoPackage = inputs.imako.packages.${pkgs.system}.default;
  myVault = "/home/srid/Dropbox/Vault";
in
{
  imports = [
    inputs.emanote.homeManagerModule
  ];

  services.emanote = {
    enable = true;
    notes = [
      myVault
    ];
    # port = 7000;
    package = inputs.emanote.packages.${pkgs.system}.default;
  };

  # TODO: Upstream as module
  # port = 4009 (hardcoded)
  systemd.user.services.imako = {
    Unit = {
      Description = "Imako for Obsidian";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${imakoPackage}/bin/imako ${myVault}";
      # Restart = "always";
      # RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
