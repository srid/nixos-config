{ config, pkgs, ... }:
let
  # Suckless Terminal provides good performance. Just need to increase the
  # fontsize on retina display.
  myst = pkgs.writeScriptBin "myst"
    ''
      #!${pkgs.runtimeShell}
      # Use fc-list to lookup font names
      exec ${pkgs.st}/bin/st -f "Iosevka:pixelsize=26" $*
    '';
in
{
  environment.systemPackages = with pkgs; [
    myst
    alacritty
  ];
}
