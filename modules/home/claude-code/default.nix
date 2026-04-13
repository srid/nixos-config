{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tree
  ];

  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      skipDangerousModePermissionPrompt = true;
      attribution = {
        commit = "";
      };
      # Un-nerf Claude Opus in Claude Code
      # See: https://x.com/kunchenguid/status/2043720881990725868
      effortLevel = "high";
      env = {
        CLAUDE_CODE_DISABLE_1M_CONTEXT = "1";
        CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
        CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
        CLAUDE_SUBAGENT_MODEL = "sonnet";
      };
    };
  };
}
