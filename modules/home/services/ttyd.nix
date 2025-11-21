# Limitations:
# - tmux session must be launched first outside of systemd.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ttyd;
in
{
  options.services.ttyd = {
    enable = mkEnableOption "ttyd web terminal service";

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "Port number for ttyd to listen on";
    };

    command = mkOption {
      type = types.str;
      default = "${pkgs.bash}/bin/bash";
      description = "Command to execute in the terminal";
    };

    write = mkOption {
      type = types.bool;
      default = false;
      description = "Allow clients to write to the terminal";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ttyd ];

    systemd.user.services.ttyd = {
      Unit = {
        Description = "ttyd web terminal service";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.ttyd}/bin/ttyd -p ${toString cfg.port}${optionalString cfg.write " -W"} ${cfg.command}";
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
