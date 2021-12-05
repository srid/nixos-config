{ config, pkgs, lib, ... }:

# A separate container to run Hercules effects
# https://docs.hercules-ci.com/hercules-ci/effects/
{
  containers.hercules = {
    ephemeral = false;
    autoStart = true;
    config = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ ];
    };
  };
}
