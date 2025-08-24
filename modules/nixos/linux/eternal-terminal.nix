{ config, lib, ... }:

{
  services.eternal-terminal.enable = true;

  # Automatically open firewall port for eternal-terminal
  networking.firewall.allowedTCPPorts = lib.optional
    config.services.eternal-terminal.enable
    config.services.eternal-terminal.port;
}
