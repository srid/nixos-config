# Juspay's coding agents from agent-distro: omp, codex and claude, carrying
# juspay/skills + kolu; omp also goes through Juspay's LiteLLM gateway.
#
# Installed through agent-distro's Home Manager module, which puts shims on
# PATH and refreshes them daily from `flake`; a shim runs the flake-pinned
# bundle until the first successful update.

{ flake, config, ... }:
let
  inherit (flake) inputs;
  homeMod = inputs.self + /modules/home;
in
{
  imports = [
    "${homeMod}/agenix.nix"
    inputs.agent-distro.homeManagerModules.default
  ];

  services.agent-distro = {
    enable = true;
    profile = "juspay";
  };

  # omp prompts for this when unset; agenix supplies it.
  age.secrets.juspay-anthropic-api-key.file =
    inputs.self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = ''
    export LITELLM_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export LITELLM_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
