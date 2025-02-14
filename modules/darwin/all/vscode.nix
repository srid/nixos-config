{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs # VSCode webhint
  ];
}
