# Juspay's coding agents, from juspay/AI's own packages.
#
# `omp` comes from coding-agents/omp/default.nix: it exports the gateway base
# URL, prompts for LITELLM_API_KEY when it is unset, seeds ~/.omp/agent/config.yml
# once, and loads the skills plugin with `omp -e`. It leaves omp's own agent
# directory alone, so sessions, auth and the config we do not own persist.
#
# `claude` and `codex` are launchers over the upstream binaries
# (sadjow/claude-code-nix, sadjow/codex-cli-nix) that carry the same shared
# skills + kolu plugins. They do no gateway wiring: each keeps its own
# authentication and config (~/.claude, ~/.codex), exactly as the curl
# installers left them.
#
# `.default` is the interactive picker (`ai`), which needs a tty and only
# chooses among the three, so name the launchers explicitly.

{ flake, config, pkgs, ... }:
let
  homeMod = flake.inputs.self + /modules/home;
  agents = flake.inputs.juspay-ai.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ "${homeMod}/agenix.nix" ];

  home.packages = [ agents.omp agents.claude agents.codex ];

  # The omp launcher asks for the key when it is unset. Ours comes from agenix,
  # under the name omp's own LiteLLM support reads.
  age.secrets.juspay-anthropic-api-key.file =
    flake.inputs.self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = ''
    export LITELLM_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export LITELLM_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
