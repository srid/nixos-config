{ config, pkgs, lib, inputs, ... }:

# https://github.com/hercules-ci/hercules-ci-agent/blob/master/templates/nixos/flake.nix
# https://docs.hercules-ci.com/hercules-ci/getting-started/deploy/nixos/
{
  imports = [
    inputs.hercules-ci-agent.nixosModules.agent-service
  ];
  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 6;
}
