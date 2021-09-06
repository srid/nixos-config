{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs-14_x # Need this for https://nixos.wiki/wiki/Vscode
  ];
}
