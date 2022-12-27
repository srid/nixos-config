{ pkgs, lib, inputs, system, ... }:

{
  # on macOS, emacs can be launched via:
  #
  # open -a ~/Applications/Home\ Manager\ Apps/Emacs.app
  programs.emacs = {
    enable = true;
    package =
      let
        emacsPgtkWithXwidgets = inputs.emacs-overlay.packages.${system}.emacsPgtk.override {
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
  };
}
