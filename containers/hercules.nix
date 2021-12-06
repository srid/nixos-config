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

  # FIXME: User id of `hercules-ci-agent` won't match that of guest, so we do
  # this. But it compromises security.  See
  # https://github.com/hercules-ci/hercules-ci-agent/issues/345#issuecomment-986329977
  # 
  # TODO: Find a way to resolve this.
  nix.allowedUsers = [ "*" ];
  nix.trustedUsers = [ "*" ];

  containers.hercules = {
    ephemeral = false;
    autoStart = true;
    config = { config, pkgs, ... }: {
      imports = [
        inputs.hercules-ci-agent.nixosModules.agent-service
      ];
      services.hercules-ci-agent.enable = true;
      services.hercules-ci-agent.settings.concurrentTasks = 4;
      services.hercules-ci-agent.settings.nixUserIsTrusted = lib.mkForce false;

      networking.firewall.allowedTCPPorts = [ ];
    };
  };
}
