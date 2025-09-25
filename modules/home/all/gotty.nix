# Limitations:
# - tmux session must be launched first outside of systemd.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gotty;
in
{
  options.services.gotty = {
    enable = mkEnableOption "GoTTY web terminal service";

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "Port number for GoTTY to listen on";
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
    home.packages = [ pkgs.gotty ];

    systemd.user.services.gotty = {
      Unit = {
        Description = "GoTTY web terminal service";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.gotty}/bin/gotty -p ${toString cfg.port}${optionalString cfg.write " -w"} ${cfg.command}";
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
