{ pkgs, inputs, ... }:
let emacs = pkgs.emacsUnstable;
in
{
  nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
  environment.systemPackages = [
    emacs

    (pkgs.writeScriptBin "em"
      '' 
        #!${pkgs.runtimeShell}
        set -xe
        TERM=xterm-direct exec ${emacs}/bin/emacs -nw $*
      '')
  ];

  fonts.fonts = with pkgs; [
    emacs-all-the-icons-fonts
  ];
}
