{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xorg.xdpyinfo
    xorg.xrandr
    xsel
    arandr
    autorandr
  ];
}
