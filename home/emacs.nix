# On macOS, launch Emacs using Raycast launcher.
# Or:
#
#   open -a ~/Applications/Home\ Manager\ Apps/Emacs.app
{ pkgs, flake, ... }:

{
  imports = [ flake.inputs.nix-doom-emacs.hmModule ];

  programs.doom-emacs = {
    enable = true;
    emacsPackage = pkgs.emacs29-pgtk;
    doomPrivateDir = ./emacs/doom;
  };

  home.packages = with pkgs; [
    # For org-roam
    graphviz
    # Doom prerequisites
    fd
    ripgrep
  ];
}
