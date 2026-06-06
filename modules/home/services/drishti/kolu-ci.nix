{ lib, ... }:
let
  # kolu-ci-1 .. kolu-ci-8
  ciHosts = map (n: "kolu-ci-${toString n}") (lib.range 1 8);
in
{
  # The CI hosts are reachable only *through* pureintent, so hop via ProxyJump.
  # `ssh kolu-ci-N` then works transparently — and so does drishti's agent
  # spawn / nix-system probe / `nix copy`, which are all just `ssh <host>`.
  # See drishti's "Hosts behind a bastion (SSH hops)" docs (PR #50).
  # NOTE: drishti forces BatchMode=yes, so pureintent must be key-based
  # (non-interactive) from wherever this runs — which it already is.
  programs.ssh.matchBlocks = lib.genAttrs ciHosts (_name: {
    proxyJump = "pureintent";
  });
}
