# On macOS, launch Emacs using Raycast launcher.
# Or:
#
#   open -a ~/Applications/Home\ Manager\ Apps/Emacs.app
{ pkgs, flake, ... }:

let
  myEmacs = pkgs.emacs29-macport.override {
    # ⚠️ Broken on Darwin
    # https://github.com/NixOS/nixpkgs/issues/110218
    # withXwidgets = true;

    # ^ We need xwidgets for embedded browser in Emacs, which is useful for
    # previewing notes.
  };
in
{
  imports = [ flake.inputs.nix-doom-emacs.hmModule ];

  # Enable one or the other below.

  # If using doom emacs ...
  programs.doom-emacs = {
    enable = true;
    emacsPackage = myEmacs;
    doomPrivateDir = ./emacs/doom;
  };

  # If using vanilla emacs ...
  /*
    programs.emacs = {
    enable = true;
    package = myEmacs;
    extraPackages = epkgs: [
      epkgs.org-roam
      epkgs.vterm
    ];
    };
  */

  home.packages = with pkgs; [
    # For org-roam
    graphviz
    # Doom prerequisites
    fd
    ripgrep
  ];
}
