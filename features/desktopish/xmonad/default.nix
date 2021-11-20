{ config, pkgs, ... }:

let
  myXmonadProject = ./xmonad-srid;
in
{
  environment.systemPackages = with pkgs; [
    xorg.xdpyinfo
    xorg.xrandr
    arandr
    autorandr

    dmenu
    gmrun
    dzen2
  ];

  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      haskellPackages = pkgs.haskellPackages.extend
        (import "${myXmonadProject}/overlay.nix" { inherit pkgs; });
      extraPackages = hpkgs: with pkgs.haskell.lib; [
        hpkgs.xmonad-contrib
        hpkgs.xmonad-extras
      ];
      # enableContribAndExtras = true;  -- using our own
      config = pkgs.lib.readFile "${myXmonadProject}/Main.hs";
    };
  };
  services.xserver.displayManager.defaultSession = "none+xmonad";

}
