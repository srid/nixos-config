# https://github.com/Alexays/Waybar/wiki/Configuration
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        # output = [ "eDP-1" ]; # Laptop screen only
        height = 30;
        modules-center = [
          # "hyprland/window"
          "clock"
        ];
        modules-right = [
          "hyprland/workspaces"
          "cpu"
          "memory"
          "backlight"
          "battery"
          "network"
          "tray"
          "custom/power"
        ];
        "hyprland/workspaces" = {
          # active-only = true;
          # all-outputs = true;
          show-special = true;
          /*
          format = "{name}{icon}";
          format-icons = {
            active = "";
            default = "";
          };
          */
        };
        "cpu" = {
          format = "{}% ";
        };
        "memory" = {
          format = "{}% ";
        };
        network = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "  {ifname}";
          format-disconnected = "⚠  Disconnected";
          tooltip-format = "{ifname} via {gwaddr}";
          on-click = "nm-connection-editor";
        };
        "clock" = {
          format = "{:%H:%M}  ";
          format-alt = "{:%A, %B %d, %Y (%R)}  ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'>{}</span>";
              weeks = "<span color='#99ffdd'>{}</span>";
              weekdays = "<span color='#ffcc66'>{}</span>";
              today = "<span color='#ffee99'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            "on-click-right" = "mode";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };
      };
    };
  };
}
