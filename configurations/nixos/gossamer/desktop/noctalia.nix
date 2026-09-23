{
  programs.noctalia = {
    enable = true;
    systemd = {
      enable = true;
      # Do not attach to graphical-session.target: Plasma uses that too.
      target = "niri.service";
    };
  };

  home-manager.sharedModules = [
    {
      xdg.configFile."noctalia/shell.toml".text = ''
        [shell]
        polkit_agent = true

        [location]
        auto_locate = false
        address = "Quebec City, Quebec, Canada"

        [weather]
        enabled = true

        # Hold the warm temperature all day, independent of location or sunset.
        [nightlight]
        enabled = true
        force = true
        temperature_night = 4500

        [dock]
        enabled = true
        auto_hide = true
        # Let windows use the dock's area; the revealed dock overlays them.
        reserve_space = false
      '';
      # Shell-specific bindings live alongside the shell, not in the compositor.
      xdg.configFile."niri/noctalia.kdl".text = ''
        binds {
          Mod+Space { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
          Mod+S { spawn "noctalia" "msg" "panel-toggle" "control-center"; }
          Mod+Comma { spawn "noctalia" "msg" "settings-toggle"; }
          Mod+L { spawn "noctalia" "msg" "session" "lock"; }
          Alt+Tab { spawn "noctalia" "msg" "window-switcher"; }
          XF86AudioRaiseVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-up"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-down"; }
          XF86AudioMute allow-when-locked=true { spawn "noctalia" "msg" "volume-mute"; }
          XF86MonBrightnessUp allow-when-locked=true { spawn "noctalia" "msg" "brightness-up"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "noctalia" "msg" "brightness-down"; }
        }
      '';
    }
  ];
}
