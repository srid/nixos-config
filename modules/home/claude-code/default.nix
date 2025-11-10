{ flake, pkgs, lib, ... }:
let
  claudeCodeDir = flake.inputs.self + /claude-code;

  subagentsDir = claudeCodeDir + "/subagents";
  agents = lib.mapAttrs'
    (fileName: _:
      lib.nameValuePair
        (lib.removeSuffix ".md" fileName)
        (builtins.readFile (subagentsDir + "/${fileName}"))
    )
    (builtins.readDir subagentsDir);

  commandsDir = claudeCodeDir + "/commands";
  commands = lib.mapAttrs'
    (fileName: _:
      lib.nameValuePair
        (lib.removeSuffix ".md" fileName)
        (builtins.readFile (commandsDir + "/${fileName}"))
    )
    (builtins.readDir commandsDir);

  skillsDir = claudeCodeDir + "/skills";
  skillDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir);

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

  mcpDir = claudeCodeDir + "/mcp";
  mcpServers = lib.mapAttrs'
    (fileName: _:
      lib.nameValuePair
        (lib.removeSuffix ".nix" fileName)
        (import (mcpDir + "/${fileName}"))
    )
    (builtins.readDir mcpDir);
in
{
  # Packages often used by Claude Code CLI.
  home.packages = with pkgs; [
    tree
  ];

  # Link skill directories to ~/.claude/skills/
  # (home-manager module doesn't support skills yet, so we link manually)
  home.file = lib.mapAttrs'
    (skillName: _:
      lib.nameValuePair ".claude/skills/${skillName}" {
        source = processSkill skillName;
        recursive = true;
      }
    )
    skillDirs;
  programs.claude-code = {
    enable = true;

    # Use sandboxed version on Linux, plain version on macOS
    package =
      if pkgs.stdenv.isLinux
      then flake.inputs.self.packages.${pkgs.system}.claude # see claude-sandboxed.nix
      else pkgs.claude-code;

    # Basic settings for Claude Code
    settings = import (claudeCodeDir + "/settings.nix");

    # System prompt / memory
    memory.text = builtins.readFile (claudeCodeDir + "/memory.md");

    # Automatically discovered commands from commands/ directory
    commands = commands;

    # Automatically discovered agents from subagents/ directory
    agents = agents;

    # Automatically discovered MCP servers from mcp/ directory
    mcpServers = mcpServers;
  };
}
