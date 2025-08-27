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
in
{
  programs.claude-code = {
    enable = true;

    # Wrapped Claude Code with Google Vertex AI auth
    # See https://github.com/juspay/vertex
    package = flake.inputs.vertex.packages.${pkgs.system}.default;

    # Basic settings for Claude Code
    settings = {
      enableAllProjectMcpServers = true;
      permissions = {
        defaultMode = "plan";
        allow = [
          "Bash(nix develop:*)"
          "Bash(nix build:*)"
          "Bash(om ci)"
          "Bash(rg:*)"
        ];
      };
    };

    # Custom commands can be added here
    commands = {
      "om-ci" = ''
        #!/bin/bash
        # Run local CI (Nix)
        om ci
      '';
    };

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
