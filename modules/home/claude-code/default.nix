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
    pkgs.tree
    pkgs.python313Packages.markitdown
    flake.inputs.self.packages.${pkgs.system}.claude # Sandboxed version from claude-sandboxed.nix
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
