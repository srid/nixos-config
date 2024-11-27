{ pkgs, lib, ... }:
{
  imports = [
    ./fix-cursor.nix
    ./waybar.nix
    ./settings.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
  };
  services.dunst.enable = true;

  programs.hyprlock.enable = true;
  programs.rofi = {
    enable = true;
    terminal = lib.getExe pkgs.rio;
    plugins = [ pkgs.rofi-emoji ];
  };
}
