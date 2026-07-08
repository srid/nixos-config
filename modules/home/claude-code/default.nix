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
      # Stop Claude from crawling /nix (the store is huge and ripgrep/find
      # over it wedges sessions).
      permissions.deny = [
        "Bash(bfs /nix*)"
        "Bash(grep * /nix*)"
        "Bash(rg * /nix*)"
        "Bash(find /nix*)"
        "Bash(fd * /nix*)"
      ];
    };
  };
}
