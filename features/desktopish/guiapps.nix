{ pkgs, ... }: {
  # Apps I use on desktops and laptops
  environment.systemPackages = with pkgs; [
    brave
    vscode
    nodejs-14_x # Need this for https://nixos.wiki/wiki/Vscode
  ];

}
