{ config, pkgs, lib, inputs, ... }:

# A separate container to run Hercules effects
# https://docs.hercules-ci.com/hercules-ci/effects/
{
  containers.hercules = {
    ephemeral = false;
    autoStart = true;
    config = { config, pkgs, ... }: {
      imports = [
        (inputs.hercules-ci-agent + "/module.nix")
        /* (builtins.fetchTarball
          {
          url = "https://github.com/hercules-ci/hercules-ci-agent/archive/ecac058b7633f969350cbc22e8c8a7466bcbc13f.tar.gz";
          sha256 = "sha256-I7Npzb0Zf58b68o1FDDphg2FsHp/V/Jhub3DzSXIBE4=";
          }
          + "/module.nix"
          ) */
      ];
      # Enabling this triggers https://github.com/hercules-ci/hercules-ci-agent/issues/341
      #services.hercules-ci-agent.enable = true;
      #services.hercules-ci-agent.concurrentTasks = 4;

      networking.firewall.allowedTCPPorts = [ ];
    };
  };
}
