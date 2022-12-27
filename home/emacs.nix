{ pkgs, lib, inputs, system, ... }:

{
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
      myEmacs.passthru.pkgs.emacsWithPackages (epkgs: [
        epkgs.vterm
      ]);
  };

}
