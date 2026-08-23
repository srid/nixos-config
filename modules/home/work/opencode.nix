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
  programs.opencode-juspay.settings = {
    permission = "allow";
    # Default model (replaces upstream litellm/glm-latest). CLI --model still
    # overrides for a one-off session.
    model = "litellm/kimi-k3";
  };

  # TUI settings (theme, keybinds, ...) live in tui.json since opencode v1.2.15.
  # programs.opencode-juspay has no TUI option, so use upstream home-manager's
  # programs.opencode for *only* this: it won't write opencode.json while
  # `settings` stays empty (juspay owns that file), and `package = null` keeps
  # the llm-agents binary installed below.
  programs.opencode = {
    enable = true;
    package = null;
    tui = {
      theme = "rosepine";
      # Desktop notification + sound when a turn finishes or input is needed.
      # OpenTUI's loaded-sound decoder is WAV/FLAC/MP3 only, so convert the
      # freedesktop .oga (Vorbis) files at build time.
      attention = let
        stereo = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo";
        toWav =
          src: name:
          pkgs.runCommand name { nativeBuildInputs = [ pkgs.ffmpeg-headless ]; } ''
            ffmpeg -loglevel error -i ${src} -f wav "$out"
          '';
        bell = toWav "${stereo}/bell.oga" "opencode-bell.wav";
        alarm = toWav "${stereo}/alarm-clock-elapsed.oga" "opencode-alarm.wav";
      in {
        enabled = true;
        notifications = true;
        sound = true;
        volume = 1.0;
        sounds = {
          default = "${bell}";
          error = "${bell}";
          done = "${bell}";
          subagent_done = "${bell}";
          # needs-you-now events get the alarm
          question = "${alarm}";
          permission = "${alarm}";
        };
      };
    };
  };

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
