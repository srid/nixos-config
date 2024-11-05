{ pkgs, lib, ... }:

let
  blue-light-filter = ./old-config/blue-light-filter.glsl;
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    meta.description = ''
      Blue-light filter screenshot script for Hyprland. Directly copies region to clipboard.
    '';
    runtimeInputs = with pkgs; [ hyprshade hyprshot ];
    text = ''
      # Turn off blue light filter
      hyprshade off
      # Take a screenshot of a region and copy it to clipboard
      hyprshot --clipboard-only -m region
      # Turn on blue light filter
      hyprshade on ${blue-light-filter}
    '';
  };
in
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    bind = [
      "$mainMod, R, exec, walker"
      "$mainMod, Q, exec, rio"
      "$mainMod, T, exec, ${lib.getExe screenshot}"
    ];

    exec-once = [
      "hyprshade on ${blue-light-filter}"
    ];

    monitor = [
      # Laptop screen (OLED 2k)
      ",highres,auto,2"
      # Apple Studio Display
      "DP-5,highres,auto-up,2"
      "DP-6,disable" # Same as DP-5
    ];

    #env = [
    #  "XCURSOR_SIZE,24"
    #  "HYPRCURSOR_SIZE,24"
    #];

    input = {
      follow_mouse = 1;
      natural_scroll = true;
      kb_options = "ctrl:nocaps";
    };
  };
}
