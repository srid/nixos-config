# Exports LITELLM_API_KEY (Juspay's LiteLLM gateway) from agenix.

{ flake, config, ... }:
let
  inherit (flake) inputs;
  homeMod = inputs.self + /modules/home;
in
{
  imports = [
    "${homeMod}/agenix.nix"
  ];

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
