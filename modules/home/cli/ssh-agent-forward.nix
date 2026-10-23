# Hosts we log into with the local ssh agent forwarded. Kept apart from
# `gui/1password.nix`: which agent backs $SSH_AUTH_SOCK (1Password, gcr, or an
# agent forwarded to us) is independent of where we forward it.
{ lib, ... }:
{
  programs.ssh.settings = lib.genAttrs [
    "naiveintent"
    "petit"
    "pureintent"
    "sincereintent"
  ] (_: {
    ForwardAgent = true;
  });
}
