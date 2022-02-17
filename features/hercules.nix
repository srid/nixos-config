{ config, pkgs, lib, inputs, ... }:

# https://docs.hercules-ci.com/hercules-ci/effects/
{
  imports = [
    inputs.hercules-ci-agent.nixosModules.agent-service
  ];
  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 16;
}
