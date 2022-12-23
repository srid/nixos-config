{ config, pkgs, lib, inputs, ... }:

# https://github.com/hercules-ci/hercules-ci-agent/blob/master/templates/nixos/flake.nix
# https://docs.hercules-ci.com/hercules-ci/getting-started/deploy/nixos/
{
  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 6;
}
