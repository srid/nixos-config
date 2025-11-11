{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claude-code;

  # Auto-wire subagents from subagents/ directory
  subagentsDir = cfg.autoWire.dir + "/subagents";
  autoAgents = lib.optionalAttrs (builtins.pathExists subagentsDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".md" fileName)
          (builtins.readFile (subagentsDir + "/${fileName}"))
      )
      (builtins.readDir subagentsDir));

  # Auto-wire commands from commands/ directory
  commandsDir = cfg.autoWire.dir + "/commands";
  autoCommands = lib.optionalAttrs (builtins.pathExists commandsDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".md" fileName)
          (builtins.readFile (commandsDir + "/${fileName}"))
      )
      (builtins.readDir commandsDir));

  # Auto-wire skills from skills/ directory
  skillsDir = cfg.autoWire.dir + "/skills";
  skillDirs = lib.optionalAttrs (builtins.pathExists skillsDir)
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir));

  # Process skill: if it has default.nix, build and substitute; otherwise use as-is
  processSkill = skillName:
    let
      skillPath = skillsDir + "/${skillName}";
      hasDefaultNix = builtins.pathExists (skillPath + "/default.nix");
    in
    if hasDefaultNix then
      let
        skillPkg = pkgs.callPackage skillPath { };
      in
      pkgs.runCommand "${skillName}-skill" { } ''
        mkdir -p $out
        substitute ${skillPath}/SKILL.md $out/SKILL.md \
          --replace-fail '@${skillName}@' '${skillPkg}/bin/${skillName}'
      ''
    else
      skillPath;

  # Auto-wire MCP servers from mcp/ directory
  mcpDir = cfg.autoWire.dir + "/mcp";
  autoMcpServers = lib.optionalAttrs (builtins.pathExists mcpDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".nix" fileName)
          (import (mcpDir + "/${fileName}"))
      )
      (builtins.readDir mcpDir));

  # Auto-load settings from settings.nix
  settingsFile = cfg.autoWire.dir + "/settings.nix";
  autoSettings = lib.optionalAttrs (builtins.pathExists settingsFile)
    (import settingsFile);

  # Auto-load memory from memory.md
  memoryFile = cfg.autoWire.dir + "/memory.md";
  autoMemory = lib.optionalAttrs (builtins.pathExists memoryFile)
    { text = builtins.readFile memoryFile; };

in
{
  options.programs.claude-code = {
    autoWire = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically wire up subagents, commands, skills, and MCP servers from autoWire.dir.
          Set to false if you want to manually configure these.
        '';
      };

      dir = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to the claude-code directory containing subagents/, commands/, skills/, mcp/, settings.nix, and memory.md.
          When set, these will be automatically discovered and configured.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.autoWire.dir != null && cfg.autoWire.enable) {
    # Link skill directories to ~/.claude/skills/
    home.file = lib.mapAttrs'
      (skillName: _:
        lib.nameValuePair ".claude/skills/${skillName}" {
          source = processSkill skillName;
          recursive = true;
        }
      )
      skillDirs;

    programs.claude-code = {
      # Auto-wire settings if settings.nix exists
      settings = lib.mkDefault autoSettings;

      # Auto-wire memory if memory.md exists
      memory = lib.mkDefault autoMemory;

      # Auto-wire commands from commands/ directory
      commands = lib.mkDefault autoCommands;

      # Auto-wire agents from subagents/ directory
      agents = lib.mkDefault autoAgents;

      # Auto-wire MCP servers from mcp/ directory
      mcpServers = lib.mkDefault autoMcpServers;
    };
  };
}
