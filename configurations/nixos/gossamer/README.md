# Gossamer — Dell XPS 16 (2026)

**XPS 16 DA16260**, Intel, x86_64, running NixOS with KDE Plasma 6 and an
alternate Niri + Noctalia session.

- Uses systemd-boot (UEFI) and `pkgs.linuxPackages_latest`.
- Uses encrypted ext4 root, encrypted swap, and an EFI partition.
- Enables Intel microcode and NPU support.
- `camera.nix` uses Intel's IPU7 hardware image processor and OV08X40 sensor
  tuning, with pinned HAL patches from Omarchy for the Linux 7.2 CVS bridge.
  It exposes an upright 4K (3840×2160) V4L2 camera to browsers through
  `v4l2-relayd`; the competing libcamera software ISP is disabled.
- Uses `nixos-hardware`'s Intel graphics support with Xe and hardware video
  acceleration. Dell Adaptive charging adjusts battery charging to usage.
- `desktop/input.nix` shares Caps-as-Ctrl and natural-scrolling preferences
  between Plasma and Niri, with touchpad scrolling at half speed.
- `apple-studio-display.nix` enables Bolt and installs `asdbctl` with its udev
  rules. Authorize/enroll the display with `boltctl` once, then use
  `asdbctl get`, `asdbctl up`, or `asdbctl down` for brightness.
  KDE shortcuts: **Meta+F1** dims it; **Meta+F2** brightens it.
- `dell-xps-16.nix` backports the upstream Intel CVS camera-driver GPIO fix
  for Linux 7.2.7. Without it, the camera driver blocks all four speaker
  amplifiers and no sound card appears ([upstream issue](https://github.com/thesofproject/sof/issues/11152)).
  Remove the backport when the selected kernel includes the fix.
- Adds Home Manager, the repo's base terminal tools (including `gh`), 1Password,
  garbage collection, and zram.
- Enables Bluetooth with KDE's Bluetooth controls and powers the adapter on at boot.
- Enables the work jumphost, its local SOCKS5 proxy on port 1080, and `juspay-run`.
- Includes `xyne-boxes` and `pu`, routed through the jumphost proxy.
- Includes vanilla Codex and Claude launchers from `agent-distro`, using personal
  authentication without Juspay gateway credentials.
- Runs Kolu as a Home Manager service and enables Tailscale, with the official
  `tailscale systray` app starting automatically at Plasma or Niri login.
  Kolu is available at `http://gossamer:7692` locally and over Tailscale MagicDNS,
  or at `http://100.94.142.87:7692` using this laptop's Tailscale IP. It listens
  on all IPv4 addresses; the firewall allows remote access only on `tailscale0`.
  Tailscale Serve also provides `https://gossamer.rooster-blues.ts.net` privately
  within the tailnet; Funnel is not enabled.
  Tailscale settings and the tray autostart live in `tailscale.nix`.

## Desktop sessions

Log out and choose **Niri** in SDDM's session selector. Choose **Plasma (Wayland)**
to return; Plasma remains the configured default. No reboot is needed to switch.

`desktop/default.nix` composes the sessions. `plasma.nix` and `niri.nix` adapt
shared input preferences to their respective desktops. `noctalia.nix` owns the
Niri shell, launcher, tray, notifications, and controls. `power.nix` owns lid and
idle policy; hardware support stays in the host's hardware modules.

Noctalia runs only in Niri. It locks after 10 idle minutes, turns screens off
after 11, and locks and suspends after 30; idle inhibitors are respected.
Logind suspends on lid close unless docked, and Noctalia locks before sleep.
Plasma uses its own power settings. Both sessions share NetworkManager,
Bluetooth, PipeWire, UPower, and power-profiles-daemon. Niri uses the GNOME
screen-sharing portal and GTK file chooser; Plasma retains its KDE portals.

Niri detects monitor hotplug and toggles the built-in panel with the lid.
`desktop/displays.nix` sets scales of 1.55 (laptop) and 2.25 (Studio Display).
The current Studio Display connection uses DP-1 at 5K; DP-2, its spare MST tile,
is disabled. Review these connector-specific rules when changing docks/cabling.

Niri shortcuts (Meta is the Windows key):

| Shortcut | Action |
| --- | --- |
| Meta+Space / Meta+S | Launcher / control center |
| Meta+Enter / Meta+E | Terminal / files |
| Meta+arrows | Focus windows or columns |
| Meta+Shift+arrows | Move windows or columns |
| Meta+PageUp / PageDown | Switch workspaces |
| Meta+F / Meta+Shift+F | Maximize column / fullscreen |
| Meta+V / Meta+Q | Toggle floating / close window |
| Meta+L | Lock |
| Meta+F1 / F2 | Studio Display brightness down / up |
| Print / Meta+? | Screenshot / shortcut list |
| Ctrl+Alt+Delete | Exit Niri (with confirmation) |

For another laptop, generate your own `hardware-configuration.nix` and replace
the encrypted swap UUID in `configuration.nix` too. These disk identifiers are
specific to this installation. Keep `system.stateVersion` at your original
installation's value, and review the repo's personal configuration before
reusing it.

Build from the repository root (the `path:` form includes untracked files):

```sh
nix --extra-experimental-features 'nix-command flakes' build \
  path:.#nixosConfigurations.gossamer.config.system.build.toplevel --no-link
```

To activate, use `just activate gossamer` from the repository's Nix devShell.
Reboot after kernel changes.
