{ flake, pkgs, lib, config, ... }:

let
  inherit (flake) inputs;
  imakoPackage = inputs.imako.packages.${pkgs.system}.default;
  myVault = "${config.home.homeDirectory}/Dropbox/Vault";
in
{
  imports = [
    inputs.emanote.homeManagerModule
  ];

  services.emanote = {
    enable = true;
    notes = [ myVault ];
    port = 7000;
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
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  launchd.agents.imako = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${imakoPackage}/bin/imako" myVault ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/imako.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/imako.err";
    };
  };
}
