{ config, pkgs, ... }:
let
  screenshot = pkgs.writeScriptBin "screenshot"
    '' 
    #!${pkgs.runtimeShell}
    ${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
  '';
in
{
  environment.systemPackages = with pkgs; [
    screenshot
  ];
}
