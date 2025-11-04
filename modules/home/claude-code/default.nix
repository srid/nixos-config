{ flake, pkgs, lib, ... }:
let
  subagentsDir = ./subagents;
  agents = lib.mapAttrs'
    (fileName: _:
      lib.nameValuePair
        (lib.removeSuffix ".md" fileName)
        (builtins.readFile (subagentsDir + "/${fileName}"))
    )
    (builtins.readDir subagentsDir);

  commandsDir = ./commands;
  commands = lib.mapAttrs'
    (fileName: _:
      lib.nameValuePair
        (lib.removeSuffix ".md" fileName)
        (builtins.readFile (commandsDir + "/${fileName}"))
    )
    (builtins.readDir commandsDir);

  skillsDir = ./skills;
  skillDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir);
in
{
  # Link skill directories to ~/.claude/skills/
  # (home-manager module doesn't support skills yet, so we link manually)
  home.file = lib.mapAttrs'
    (skillName: _:
      lib.nameValuePair ".claude/skills/${skillName}" {
        source = skillsDir + "/${skillName}";
        recursive = true;
      }
    )
    skillDirs;

  home.packages = [
    pkgs.tree
    pkgs.python313Packages.markitdown
    # Use sandboxed version on Linux, plain version on macOS
    (if lib.hasInfix "linux" pkgs.system
    then flake.inputs.self.packages.${pkgs.system}.claude
    else pkgs.claude-code)
    # Other agents for trying out
    pkgs.copilot-cli
  ];
  programs.claude-code = {
    enable = true;
    package = null; # See above

    # Basic settings for Claude Code
    settings = {
      theme = "dark";
      permissions = {
        defaultMode = "bypassPermissions";
      };
      # Disable Claude from adding itself as co-author to commits
      includeCoAuthoredBy = false;
    };

    # System prompt / memory
    memory.text = builtins.readFile ./memory.md;

    # Automatically discovered commands from commands/ directory
    commands = commands;

    # Automatically discovered agents from subagents/ directory
    agents = agents;

    # MCP servers configuration
    # Disabled, because package is null
    /*
      mcpServers = {
      "nixos-mcp" = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
      "chrome-devtools" = {
        command = "npx";
        args = [ "chrome-devtools-mcp@latest" ];
      };
      };
    */
  };
}
