# Oh My Pi on Juspay's gateway, from juspay/AI's own package.
#
# The wrapper (coding-agents/omp/default.nix, PR #166) exports the gateway base
# URL, prompts for LITELLM_API_KEY when it is unset, seeds ~/.omp/agent/config.yml
# once, and loads the skills plugin with `omp -e`. It leaves omp's own agent
# directory alone, so sessions, auth and the config we do not own persist.

{ flake, config, pkgs, ... }:
let
  homeMod = flake.inputs.self + /modules/home;
in
{
  imports = [ "${homeMod}/agenix.nix" ];

  home.packages = [
    flake.inputs.juspay-ai.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # The wrapper asks for the key when it is unset. Ours comes from agenix, under
  # the name omp's own LiteLLM support reads.
  age.secrets.juspay-anthropic-api-key.file =
    flake.inputs.self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = ''
    export LITELLM_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export LITELLM_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
