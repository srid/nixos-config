# Debug agenix logs:
#   cat ~/Library/Logs/agenix/stdout
#   cat ~/Library/Logs/agenix/stderr
{ flake, config, lib, ... }:
let
  inherit (flake.inputs) agenix;
in
{
  imports = [
    agenix.homeManagerModules.default
  ];

  # We use a separate SSH key for agenix decryption to avoid exposing the main
  # private key (which is in 1Password) to the filesystem.
  #
  # To provision this key once:
  #   ssh-keygen -t ed25519 -f ~/.ssh/agenix
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];

  # WORKAROUND: Fix agenix restart loop on Darwin
  # See: https://github.com/ryantm/agenix/issues/308
  # Permanent fix pending in: https://github.com/ryantm/agenix/pull/352
  #
  # The issue: `Crashed = false` means "restart when NOT crashed" (i.e., restart on successful exit)
  # This causes the agent to restart every 10 seconds after successful completion.
  # Solution: Remove the Crashed option entirely, only keep SuccessfulExit = false
  launchd.agents.activate-agenix.config.KeepAlive = lib.mkForce {
    SuccessfulExit = false;
  };
}
