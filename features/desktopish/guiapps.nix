{ pkgs, ... }: {
  # Apps I use on desktops and laptops
  environment.systemPackages = with pkgs; [
    brave
    vscode
    vlc
  ];

}
