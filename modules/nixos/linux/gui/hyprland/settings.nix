# See default config here:
# https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
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
      #!/bin/sh
      trap 'hyprshade on ${blue-light-filter}' EXIT
      # Turn off blue light filter
      hyprshade off
      # Take a screenshot of a region and copy it to clipboard
      hyprshot --clipboard-only -m region
    '';
  };
in
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    bind = [
      "$mainMod, Q, exec, rio"

      # Window management
      "$mainMod, C, killactive,"
      "$mainMod, J, togglesplit,"
      "$mainMod, F, fullscreen"

      # Workspace management
      # Switch
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      # Move window to workspace
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
    ];

    # Move/resize windows with mouse
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    # Fn keys
    bindl = [
      # Laptop multimedia keys for volume and LCD brightness
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      # Requires playerctl
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"

      ", XF86Favorites, exec, walker"
      ", Print, exec, ${lib.getExe screenshot}"
    ];

    exec-once = [
      "${lib.getExe pkgs.hyprshade} on ${blue-light-filter}"
    ];

    monitor = [
      # Laptop screen (OLED 2k)
      ",highres,auto,2"
      # Apple Studio Display
      "DP-5,highres,auto-up,2"
      "DP-6,disable" # Same as DP-5
    ];

    general = {
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      resize_on_border = true;
    };

    decoration = {
      rounding = 10;
      drop_shadow = true;
      shadow_range = 4;
      shadow_render_power = 3;
      "col.shadow" = "rgba(1a1a1aee)";
      blur = {
        enabled = true;
        size = 3;
      };
    };

    misc = {
      force_default_wallpaper = 2;
    };

    input = {
      follow_mouse = 1;
      natural_scroll = true;
      touchpad.natural_scroll = true;
      kb_options = "ctrl:nocaps";
    };
  };
}
