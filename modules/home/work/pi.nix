# Juspay's coding agents from juspay/AI: omp, codex and claude, carrying
# juspay/skills + kolu; omp also goes through Juspay's LiteLLM gateway.

{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  homeMod = inputs.self + /modules/home;
  agents = inputs.juspay-ai.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ "${homeMod}/agenix.nix" ];

  home.packages = [ agents.omp agents.claude agents.codex ];

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
