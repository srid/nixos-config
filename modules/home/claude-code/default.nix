{ flake, pkgs, ... }:
{
  # Import the general home-manager module
  imports = [
    ../../../claude-code/nix/home-manager-module.nix
  ];

  # Packages often used by Claude Code CLI
  home.packages = with pkgs; [
    tree
  ];

  programs.claude-code = {
    enable = true;

    # Use sandboxed version on Linux, plain version on macOS
    package =
      if pkgs.stdenv.isLinux
      then flake.inputs.self.packages.${pkgs.system}.claude # see claude-sandboxed.nix
      else pkgs.claude-code;

    # Set the claude-code directory for auto-wiring
    autoWire.dir = ../../../claude-code;
  };
}
