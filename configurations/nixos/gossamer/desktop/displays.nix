# Niri output configuration, using the scales selected in Plasma.
# Preferred modes and positioning are automatic for other displays.
''
  output "eDP-1" {
    scale 1.55
  }
  output "DP-1" {
    mode "5120x2880@60"
    scale 2.25
    position x=0 y=0
    focus-at-startup
  }
  // The Studio Display exposes a second MST tile on this connector. DP-1
  // already drives its full 5K image; enabling DP-2 creates a phantom screen.
  // Revisit this connector rule when using a different dock/display layout.
  output "DP-2" { off; }
''
