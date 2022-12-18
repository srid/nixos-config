{ pkgs, lib, inputs, system, ... }:

{
  programs.emacs = {
    enable = true;
    package = (inputs.emacs-overlay.packages.${system}.emacsPgtk.override {
      withXwidgets = true;
    }).overrideAttrs (oa: {
      buildInputs = oa.buildInputs ++ lib.optionals pkgs.stdenv.isDarwin
        [ pkgs.darwin.apple_sdk.frameworks.WebKit ];
    });
  };

  # https://docs.doomemacs.org/latest/modules/term/vterm/
  #
  # Sadly, this doesn't work yet. This is the blocker:
  # https://github.com/akermu/emacs-libvterm/issues/333#issuecomment-1272195411
  home.packages = with pkgs; [
    cmake
    libvterm-neovim
    (pkgs.writeShellApplication {
      name = "glibtool";
      runtimeInputs = [ libtool ];
      text = ''
        libtool "$@"
      '';
    })
  ];
}
