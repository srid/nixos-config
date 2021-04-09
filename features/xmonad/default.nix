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

    dmenu
    gmrun
    xmobar
    dzen2
    # For taffybar?
    hicolor-icon-theme
  ];
  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "none+xmonad";
    };
    windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
      ];
      enableContribAndExtras = true;
      config = pkgs.lib.readFile ./xmonad-srid/Main.hs;
    };

  };
}
