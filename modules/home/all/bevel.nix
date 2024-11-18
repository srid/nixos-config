{ flake, pkgs, ... }:

{
  programs.bevel = {
    enable = true; # Make the CLI available
    harness = {
      bash = {
        enable = true; # Gather history from bash
        bindings = true; # Bind C-p and C-r
      };
    };
  };
}
