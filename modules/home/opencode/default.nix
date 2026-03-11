{ pkgs, ... }:
let
  juspayProvider = import ./juspay;
in
{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
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
