{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
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
