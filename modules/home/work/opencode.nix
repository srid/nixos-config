# Juspay's opencode *configuration* (not the package), via the home-manager
# module exposed upstream by juspay/AI (homeModules.opencode).
#
# The config points opencode at Juspay's LLM gateway and authenticates with
# JUSPAY_API_KEY, which we source from the agenix-managed secret and export
# into interactive shells below.

{ flake, pkgs, config, ... }:
let
  homeMod = flake.inputs.self + /modules/home;
in
{
  imports = [
    flake.inputs.juspay-ai.homeModules.opencode
    "${homeMod}/agenix.nix"
  ];

  programs.opencode-juspay.enable = true;

  # YOLO mode: auto-approve all permission prompts in the TUI (opencode has no
  # --dangerously-skip-permissions flag for the TUI, only for `run`; see
  # https://github.com/anomalyco/opencode/issues/8463). Explicit "deny" rules
  # would still win.
  programs.opencode-juspay.settings.permission = "allow";

  # The upstream module is config-only by design; install the binary from
  # llm-agents (numtide/llm-agents.nix) so the Juspay config above is usable
  # out of the box.
  home.packages = [
    flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];

  # The Juspay litellm provider authenticates with JUSPAY_API_KEY at runtime.
  # Decrypt the secret via agenix and export it into interactive shells.
  age.secrets.juspay-anthropic-api-key.file =
    flake.inputs.self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
