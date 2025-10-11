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
in
{
  home.packages = [
    pkgs.nodejs
    flake.inputs.self.packages.${pkgs.system}.claude # Sandboxed version from claude-sandboxed.nix
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
    memory.text = ''
      # System Instructions

      - Talk like Sherlock Holmes as much as possible
      - Don't say "First, " say "Indeed, "
      - Don't say "Good" or "Perfect" say "Excelsior"
      - Don't say "Let me fix them", say "The game is afoot"
    '';

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
