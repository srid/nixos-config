{ config, pkgs, lib, inputs, ... }:

# A separate container to run Hercules effects
# https://docs.hercules-ci.com/hercules-ci/effects/
{
  # TODO: hercules ci cache here
  nix.binaryCachePublicKeys = [
    "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
  ];
  nix.binaryCaches = [
    "https://hercules-ci.cachix.org"
  ];

  containers.hercules = {
    ephemeral = false;
    autoStart = true;
    config = { config, pkgs, ... }: {
      imports = [
        inputs.hercules-ci-agent.nixosModules.agent-service
      ];
      services.hercules-ci-agent.enable = true;
      services.hercules-ci-agent.settings.concurrentTasks = 4;

      networking.firewall.allowedTCPPorts = [ ];
    };
  };
}
