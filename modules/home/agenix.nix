# Debug agenix logs:
#   cat ~/Library/Logs/agenix/stdout
#   cat ~/Library/Logs/agenix/stderr
{ flake, config, ... }:
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
}
