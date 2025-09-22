# This machine uses Omarchy
#
# So we consciously pick what we need
{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  imports = [
    "${homeMod}/claude-code"
    "${homeMod}/all/git.nix"
    "${homeMod}/all/just.nix"
    "${homeMod}/all/direnv.nix"
    "${homeMod}/all/starship.nix"
    "${homeMod}/all/bash.nix"
    "${homeMod}/all/terminal.nix"
    "${homeMod}/all/1password.nix"
  ];

  # Bash custom configuration
  programs.bash = {
    # Not using this ^ because our starship provides direnv integration.
    # bashrcExtra = ''
    #   # Omarchy integration
    #   source ~/.local/share/omarchy/default/bash/rc
    # '';
  };

  home.username = "srid";
  home.stateVersion = "25.05";
}
