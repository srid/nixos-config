{ pkgs, ... }: {
  imports = [
    ./vscode.nix
  ];

  # Apps I use on desktops and laptops
  environment.systemPackages = with pkgs; [
    brave
    # onlyoffice-bin
    obsidian

    simplescreenrecorder
    obs-studio

    vlc
    qbittorrent

    # X stuff
    caffeine-ng
    xorg.xdpyinfo
    xorg.xrandr
    xclip
    xsel
    arandr
  ];
}
