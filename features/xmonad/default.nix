{ config, pkgs, ... }:
let
  screenshot = pkgs.writeScriptBin "screenshot"
    '' 
    #!${pkgs.runtimeShell}
    ${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
  '';
  # Suckless Terminal provides good performance. Just need to increase the
  # fontsize on retina display.
  myst = pkgs.writeScriptBin "myst"
    ''
      #!${pkgs.runtimeShell}
      # Use fc-list to lookup font names
      exec ${pkgs.st}/bin/st -f "CascadiaCode:pixelsize=26" $*
    '';
in
{
  # Configure things that are not done automatically like GNOME.
  # - Set monitor DPI
  services.xserver.dpi = 192;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
        Xft.dpi: 192
        Xcursor.theme: Adwaita
        Xcursor.size: 64
    EOF
  '';
  # - Swap ctrl & caps
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.useXkbConfig = true;

  environment.systemPackages = with pkgs; [
    myst
    screenshot
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

  # TODO move to features/desktopish/terminal-st.nix
  fonts.fonts = with pkgs; [
    cascadia-code # Used by myst
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
}
