# On macOS, launch Emacs using Raycast launcher.
# Or:
#
#   open -a ~/Applications/Home\ Manager\ Apps/Emacs.app
{ pkgs, flake, ... }:

{
  imports = [ flake.inputs.nix-doom-emacs.hmModule ];

  # If using doom emacs ...
  programs.doom-emacs = {
    enable = false;
    emacsPackage = pkgs.emacs29-pgtk;
    doomPrivateDir = ./emacs/doom;
  };

  # If using vanilla emacs ...
  /* programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: [
      epkgs.org-roam
      epkgs.vterm
    ];
  }; */

  home.packages = with pkgs; [
    # For org-roam
    graphviz
    # Doom prerequisites
    fd
    ripgrep
  ];
}
