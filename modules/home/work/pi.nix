# Juspay gateway model catalog for a manually installed Oh My Pi.
# JUSPAY_API_KEY comes from ./opencode.nix.

{ flake, pkgs, ... }:
let
  juspayAI = flake.inputs.juspay-ai;
in
{
  # OMP owns config.yml so runtime preferences survive Home Manager activation.
  home.file.".omp/agent/models.yml".source =
    import (juspayAI + /coding-agents/omp/models-yaml.nix) { inherit pkgs; };
}
