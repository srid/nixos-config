{ pkgs, ... }: {
  # Apps I use on desktops and laptops
  environment.systemPackages = with pkgs; [
    brave

    vscode
    vlc
    qbittorrent

    # X stuff
    xorg.xdpyinfo
    xorg.xrandr
    xclip
    xsel
    arandr
    autorandr
  ];
}
