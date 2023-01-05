{ config, lib, pkgs, inputs, system, ... }:

{
  # TODO: use agenix to manage
  # - secrets
  # - ssh keys
  services.hercules-ci-agent = {
    enable = true;
    package = inputs.hci.packages.${system}.hercules-ci-agent;
  };
}
