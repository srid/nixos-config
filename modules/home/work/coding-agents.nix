# Juspay's coding agents from agent-distro: omp, codex and claude, carrying
# juspay/skills + kolu; omp also goes through Juspay's LiteLLM gateway.
#
# Installed through agent-distro's Home Manager module, which puts shims on
# PATH and refreshes them daily from `flake`; a shim runs the flake-pinned
# bundle until the first successful update.

{ flake, ... }:
let
  inherit (flake) inputs;
  homeMod = inputs.self + /modules/home;
in
{
  imports = [
    "${homeMod}/work/litellm.nix"
    inputs.agent-distro.homeManagerModules.default
  ];

  services.agent-distro = {
    enable = true;
    profile = "juspay";
  };
}
