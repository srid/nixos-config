# On macOS, launch Emacs using Raycast launcher.
# Or:
#
#   open -a ~/Applications/Home\ Manager\ Apps/Emacs.app
{ pkgs, lib, flake, ... }:

let
  package =
    let
      # Pgtk won't be available until emacs 29; so we must use the nightly overlay
      # cf. https://github.com/NixOS/nixpkgs/issues/192692#issuecomment-1256872679
      emacsPgtkWithXwidgets = flake.inputs.emacs-overlay.packages.${pkgs.system}.emacsPgtk.override {
        withXwidgets = true;
      };
      myEmacs = emacsPgtkWithXwidgets.overrideAttrs (oa: {
        buildInputs = oa.buildInputs ++ lib.optionals pkgs.stdenv.isDarwin
          [ pkgs.darwin.apple_sdk.frameworks.WebKit ];
      });
    in
    (pkgs.emacsPackagesFor myEmacs).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]);
in
{
  imports = [ flake.inputs.nix-doom-emacs.hmModule ];

  #programs.emacs = {
  #  enable = true;
  #  inherit package;
  #};

  programs.doom-emacs = {
    enable = true;
    # Disabling until https://github.com/nix-community/nix-doom-emacs/issues/409
    # emacsPackage = package;
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
