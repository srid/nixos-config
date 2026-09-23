{ pkgs, lib, ... }:
let
  input = import ./input.nix;
in
{
  programs.niri = {
    enable = true;
    useNautilus = false;
  };
  # Niri starts Xwayland Satellite on demand for legacy X11 applications.
  environment.systemPackages = [
    pkgs.xwayland-satellite
    pkgs.foot
  ];

  home-manager.sharedModules = [
    {
      xdg.configFile."niri/config.kdl".text = ''
        include "noctalia.kdl"
        ${import ./displays.nix}

        input {
          keyboard {
            xkb {
              layout "${input.keyboardLayout}"
              options "${input.keyboardOptions}"
            }
          }
          touchpad {
            tap
            dwt
            ${lib.optionalString input.naturalScrolling "natural-scroll"}
            scroll-factor ${toString input.touchpadScrollFactor}
          }
          mouse {
            ${lib.optionalString input.naturalScrolling "natural-scroll"}
          }
        }
        layout {
          gaps 12
          center-focused-column "on-overflow"
          default-column-width { proportion 0.5; }
          preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
          }
          focus-ring {
            width 2
            active-color "#89b4fa"
          }
        }
        prefer-no-csd
        hotkey-overlay { skip-at-startup; }
        window-rule {
          match app-id="dev.noctalia.Noctalia"
          open-floating true
        }
        binds {
          Mod+Return { spawn "${pkgs.foot}/bin/foot"; }
          Mod+E { spawn "${pkgs.kdePackages.dolphin}/bin/dolphin"; }
          Mod+Q { close-window; }
          Mod+O { toggle-overview; }
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+Left { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up { focus-window-up; }
          Mod+Down { focus-window-down; }
          Mod+Shift+Left { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up { move-window-up; }
          Mod+Shift+Down { move-window-down; }
          Mod+Page_Up { focus-workspace-up; }
          Mod+Page_Down { focus-workspace-down; }
          Mod+Shift+Page_Up { move-column-to-workspace-up; }
          Mod+Shift+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Left { focus-monitor-left; }
          Mod+Ctrl+Right { focus-monitor-right; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+V { toggle-window-floating; }
          Mod+R { switch-preset-column-width; }
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+F1 { spawn "${pkgs.asdbctl}/bin/asdbctl" "down"; }
          Mod+F2 { spawn "${pkgs.asdbctl}/bin/asdbctl" "up"; }
          Print { screenshot; }
          Ctrl+Alt+Delete { quit; }
        }
      '';
    }
  ];
}
