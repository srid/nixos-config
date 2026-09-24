{ pkgs, ... }:
let
  focusOrLaunch = pkgs.callPackage ./focus-or-launch.nix { };
  xyneSpacesAppId = "nehccadabpmiepmbehdpbccnlmgeodmk";
  kdeWallpapers = pkgs.runCommand "kde-wallpaper-gallery" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    mkdir -p "$out"
    python3 - "$out" <<'PY'
    import re
    import sys
    from pathlib import Path

    root = Path("${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers")
    for theme in sorted(root.iterdir()):
        for variant in ("images", "images_dark"):
            candidates = []
            for image in (theme / "contents" / variant).glob("*"):
                size = re.fullmatch(r"(\d+)x(\d+)", image.stem)
                if size and image.is_file():
                    width, height = map(int, size.groups())
                    # Prefer desktop aspect ratios, then the largest image.
                    candidates.append((1 <= width / height <= 2, width * height, image))
            if candidates:
                image = max(candidates)[2]
                suffix = "-dark" if variant == "images_dark" else ""
                (Path(sys.argv[1]) / (theme.name + suffix + image.suffix)).symlink_to(image)
    PY
  '';
in
{
  imports = [ ./noctalia-calendar.nix ];

  programs.noctalia = {
    enable = true;
    systemd = {
      enable = true;
      # Do not attach to graphical-session.target: Plasma uses that too.
      target = "niri.service";
    };
  };

  home-manager.sharedModules = [
    ({ config, ... }: {
      home.file."Pictures/Wallpapers/KDE".source = kdeWallpapers;
      xdg.configFile."noctalia/shell.toml".text = ''
        [shell]
        polkit_agent = true

        [widget.clock]
        format = "{:%a, %b %d · %H:%M}"

        [wallpaper]
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers/KDE"

        [wallpaper.automation]
        enabled = true
        interval_seconds = 21600
        order = "random"

        [hot_corners]
        enabled = true
        delay_ms = 250

        [hot_corners.top_left]
        action = "command"
        command = "${pkgs.niri}/bin/niri msg action toggle-overview"

        [hot_corners.top_right]
        action = "command"
        command = "${focusOrLaunch}/bin/niri-focus-or-launch chrome-${xyneSpacesAppId}-Default ${pkgs.google-chrome}/bin/google-chrome --profile-directory=Default --app-id=${xyneSpacesAppId}"

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
        // Noctalia owns the hot corner and its activation delay.
        gestures { hot-corners { off; }; }
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
    })
  ];
}
