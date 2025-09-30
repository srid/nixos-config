{ lib, pkgs, flake, ... }:
{
  imports = [
    flake.inputs.self.homeModules.default
    flake.inputs.self.homeModules.darwin-only
    (flake.inputs.self + /modules/home/all/1password.nix)
  ];

  home.username = "srid";

  # For Zed's Claude Code to work with Anthropic Vertex
  home.sessionVariables = {
    CLAUDE_CODE_USE_VERTEX = "1";
    ANTHROPIC_VERTEX_PROJECT_ID = "dev-ai-gamma";
    ANTHROPIC_MODEL = "claude-sonnet-4-5";
  };

  home.packages = [
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.tart
  ];
}
