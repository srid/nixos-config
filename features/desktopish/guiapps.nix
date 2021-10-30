{ pkgs, ... }: {
  # Apps I use on desktops and laptops
  environment.systemPackages = with pkgs; [
    brave
    vscode
    vlc
    steam
    qbittorrent

    # X stuff
    xorg.xdpyinfo
    xorg.xrandr
    xclip
    xsel
    arandr
    autorandr
  ];

  # https://github.com/NixOS/nixpkgs/issues/47932#issuecomment-447508411
  hardware.opengl.driSupport32Bit = true;

}
