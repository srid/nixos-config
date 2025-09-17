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
    pkgs.cat-agenix-secret # Used by hackage-publish script
    pkgs.hackage-publish # Haskell package publishing script
  ];
  programs.claude-code = {
    enable = true;

    # Wrapped Claude Code with Google Vertex AI auth
    # See https://github.com/juspay/vertex
    package = flake.inputs.vertex.packages.${pkgs.system}.default;

    # Basic settings for Claude Code
    settings = {
      theme = "dark";
      permissions = {
        # defaultMode = "plan";
      };
    };

    # Automatically discovered commands from commands/ directory
    commands = commands;

    # Automatically discovered agents from subagents/ directory
    agents = agents;

    # MCP servers configuration
    mcpServers = {
      "nixos-mcp" = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
    };
  };
}
