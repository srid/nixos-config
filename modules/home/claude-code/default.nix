{ flake, pkgs, ... }:
{
  home.packages = [
    # flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    pkgs.tree
  ];

  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      skipDangerousModePermissionPrompt = true;
      attribution = {
        commit = "";
      };
      # Un-nerf Claude Opus in Claude Code
      # effortLevel = "high";
      env = {
        # CLAUDE_CODE_NO_FLICKER = "1";
        # CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
        CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
      };
    };
  };
}
