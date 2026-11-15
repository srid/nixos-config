# `just activate [host]` exports NIX_CONFIG when `oss_cache=1` (the kolu-r2
# substituter). For a remote activation it has to survive two hops that drop
# the environment by default:
#
#   1. ssh — sshd discards variables unless they are named in AcceptEnv.
#   2. sudo — nixos-unified's `sudo-nixos-rebuild` mode runs the rebuild as
#      root, and sudo's env_reset drops everything outside env_keep.
#
# Both are inert unless the caller sets NIX_CONFIG, and `extra-substituters` /
# `extra-trusted-public-keys` from it are only honoured for a trusted user
# (root, or @wheel) — see `modules/nixos/shared/nix.nix`.
{ ... }:
{
  services.openssh.settings.AcceptEnv = [ "NIX_CONFIG" ];
  security.sudo.extraConfig = ''
    Defaults env_keep += "NIX_CONFIG"
  '';
}
