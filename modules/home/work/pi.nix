# oh-my-pi (https://github.com/can1357/oh-my-pi), a fork of pi, via its
# upstream Home Manager module. Binary is `omp`.
#
# Wired to Juspay's LiteLLM gateway using the same model catalog juspay/AI
# renders for pi/opencode. Default model matches opencode.nix; CLI --model
# still overrides. JUSPAY_API_KEY comes from ./opencode.nix.

{ flake, pkgs, lib, ... }:
let
  juspayAI = flake.inputs.juspay-ai;
  catalog = import (juspayAI + /coding-agents/catalog.nix);
  yaml = pkgs.formats.yaml { };
in
{
  imports = [
    flake.inputs.oh-my-pi.homeManagerModules.default
  ];

  programs.omp = {
    enable = true;
    # HACK: upstream collab-cli.ts imports bare "chalk", which is not a
    # coding-agent dependency, so `bun build` fails under Nix. Use the
    # in-repo reimplementation like the rest of the CLI does. Drop once fixed
    # upstream (their CI only evaluates the flake, never builds it).
    package =
      flake.inputs.oh-my-pi.packages.${pkgs.stdenv.hostPlatform.system}.omp.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace packages/coding-agent/src/cli/collab-cli.ts \
            --replace-fail 'from "chalk"' 'from "@oh-my-pi/pi-utils/chalk"'
        '';
      });
    # Copied to ~/.omp/agent/config.yml on every switch, so runtime
    # /settings changes are reset then.
    settings = {
      modelRoles.default = "litellm/kimi-k3";
      # Same vendored skills pi-juspay-oneclick passed via --skill.
      skills.customDirectories = [ "${juspayAI}/.opencode/skills" ];
    };
  };

  # Read-only for omp (it only writes config.yml), so a store symlink is fine.
  home.file.".omp/agent/models.yml".source = yaml.generate "omp-models.yml" {
    providers.litellm = {
      baseUrl = catalog.gatewayUrl;
      api = "openai-completions";
      # omp resolves this as an env var name.
      apiKey = catalog.apiKeyEnv;
      models = lib.mapAttrsToList
        (id: { context, output, reasoning ? false, ... }: {
          inherit id reasoning;
          name = id;
          input = [ "text" "image" ];
          contextWindow = context;
          maxTokens = output;
        })
        catalog.models;
    };
  };
}
