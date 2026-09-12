{ pkgs, ... }:
{
  imports = [
    ./cli/bash.nix
    # ./claude-code
    # ./cli/zsh.nix
    # ./editors/vscode-server.nix
  ];

  # Agents expect `python3` on PATH (scripts, MCP, one-off tools).
  home.packages = [ pkgs.python3 ];
}
