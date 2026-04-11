{ flake, pkgs, ... }:
{
  imports = [
    flake.inputs.nix-agent-wire.homeModules.claude-code
  ];

  home.packages = with pkgs; [
    tree
  ];

  programs.claude-code = {
    enable = true;

    # Installed outside Nix (e.g., via npm) to get auto-updates.
    # This requires disabling autoWire too, since wiring MCP servers
    # needs a package to wrap.
    package = null;
    autoWire.enable = false;
  };
}
