{ pkgs, ... }: {
  # Apps I use on desktops and laptops
  environment.systemPackages = with pkgs; [
    brave
    onlyoffice-bin

    simplescreenrecorder
    obs-studio

    vscode
    vlc
    qbittorrent

    # X stuff
    caffeine-ng
    xorg.xdpyinfo
    xorg.xrandr
    xclip
    xsel
    arandr
    autorandr
  ];
}
