{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    xorg.xdpyinfo
    xorg.xrandr
    arandr
    autorandr

    dmenu
    gmrun
    xmobar
    dzen2
    # For taffybar?
    hicolor-icon-theme
  ];

  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
      ];
      enableContribAndExtras = true;
      config = pkgs.lib.readFile ./xmonad-srid/Main.hs;
    };
  };
  services.xserver.displayManager.defaultSession = "none+xmonad";

  services.autorandr = {
    enable = true;
  };
}
