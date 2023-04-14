{ pkgs, lib, flake, ... }:

{
  # on macOS, emacs can be launched via:
  #
  # open -a ~/Applications/Home\ Manager\ Apps/Emacs.app
  programs.emacs = {
    enable = true;
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
  };

  home.packages = with pkgs; [
    # For org-roam
    graphviz
  ];
}
