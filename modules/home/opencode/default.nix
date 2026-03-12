{ flake, lib, pkgs, ... }:
let
  inherit (flake.inputs) AI;
  juspayProvider = import ./juspay;
  
  commandsDir = AI + "/commands";
  autoCommands = if builtins.pathExists commandsDir then
    lib.mapAttrs'
      (fileName: _: lib.nameValuePair
        (lib.removeSuffix ".md" fileName)
        (commandsDir + "/${fileName}"))
      (builtins.readDir commandsDir)
  else { };
in
{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    commands = autoCommands;
    settings = {
      model = "litellm/glm-latest";
      # Explore agent for fast codebase search/reading tasks
      agent = {
        explore = {
          mode = "subagent";
          model = "litellm/open-fast";
        };
      };
      autoupdate = true;
      provider = {
        litellm = juspayProvider;
      };
      mcp = {
        deepwiki = {
          type = "remote";
          url = "https://mcp.deepwiki.com/mcp";
          enabled = true;
        };
      };
      plugin = [ ];
    };
  };
}
