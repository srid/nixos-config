{ flake, pkgs, ... }:
let
  inherit (flake.inputs) AI;
in
{
  # Import the general home-manager module
  imports = [
    "${AI}/nix/home-manager-module.nix"
  ];

  # Packages often used by Claude Code CLI
  home.packages = with pkgs; [
    tree
  ];

  programs.claude-code = {
    enable = true;

    # Use sandboxed version 
    package = flake.inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.claude; # see claude-sandboxed.nix

    # Set the claude-code directory for auto-wiring
    autoWire.dir = AI;
  };
}
