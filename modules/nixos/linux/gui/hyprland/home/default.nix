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
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprlock.enable = true;
  programs.rofi = {
    enable = true;
    terminal = lib.getExe pkgs.rio;
    plugins = [ pkgs.rofi-emoji ];
  };
}
