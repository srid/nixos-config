# Juspay's LiteLLM gateway for a manually installed Oh My Pi.
#
# juspay/AI dropped the generated `omp models.yml` (coding-agents/omp/models-yaml.nix
# is gone as of c7ce46c): OMP ships LiteLLM discovery and asks the gateway what it
# serves, so the base URL plus the gateway key under the name OMP expects
# (LITELLM_API_KEY) is the whole wiring. See "Oh My Pi and the LiteLLM gateway"
# in juspay/AI's README.

{ flake, config, ... }:
let
  homeMod = flake.inputs.self + /modules/home;
  catalog = import (flake.inputs.juspay-ai + /coding-agents/catalog.nix);
  apiKeyFile = config.age.secrets.juspay-anthropic-api-key.path;
  gatewayEnv = ''
    export LITELLM_BASE_URL="${catalog.gatewayUrl}"
    export LITELLM_API_KEY="$(cat "${apiKeyFile}")"
  '';
in
{
  imports = [ "${homeMod}/agenix.nix" ];

  # Same secret ./opencode.nix exports as LITELLM_API_KEY; both modules declare it.
  age.secrets.juspay-anthropic-api-key.file =
    flake.inputs.self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = gatewayEnv;
  programs.bash.initExtra = gatewayEnv;
}
