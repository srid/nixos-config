# Gossamer — Dell XPS 16 (2026)

Personal NixOS configuration for the **XPS 16 DA16260**, Intel Panther Lake,
x86_64. Plasma and Niri share the same apps, files, audio, networking, and Bluetooth.

## Getting around

Choose **Niri** or **Plasma (Wayland)** at the login screen. Niri is the default;
switching sessions requires logging out, not rebooting.

Niri lays windows out in a horizontal strip, with workspaces stacked vertically.
Noctalia provides the launcher, controls, notifications, and a bottom dock.
Move the pointer to the bottom edge to reveal the dock; windows can use its space
while hidden. A 4500 K night-light tint stays on all day.

**Meta = Windows key.** These shortcuts apply in Niri:

| Keys | Action |
| --- | --- |
| Meta+Space / Meta+S / Meta+Comma | Apps / controls / settings |
| Meta+Enter / Meta+E | Terminal / files |
| Meta+O or top-left hot corner | Overview; hold the pointer in the corner for 250 ms |
| Top-right hot corner | Focus Xyne Spaces, or launch it if closed; 250 ms delay |
| Ctrl+Alt+U | Focus Google Chrome, or launch it if closed |
| Ctrl+Alt+L | Focus the myolai PWA, or launch it if closed |
| Ctrl+Alt+K | Focus the Kolu PWA, or launch it if closed |
| Meta+arrows / Meta+Shift+arrows | Focus / move windows and columns |
| Meta+PageUp/PageDown | Switch workspace; add Shift to move a column there |
| Meta+Ctrl+Left/Right | Focus another monitor |
| Meta+R / Meta+− / Meta+= | Cycle column widths / narrower / wider |
| Meta+F / Meta+Shift+F | Maximize column / fullscreen |
| Meta+V / Meta+Q / Meta+L | Floating / close window / lock |
| Meta+F1/F2 | Studio Display brightness down/up; also works in Plasma |
| Print / F9 | Screenshot / Kooha recorder |
| Meta+Shift+/ / Ctrl+Alt+Delete | Shortcut help / logout confirmation |

In **overview**, right-drag pans horizontally, the wheel switches workspaces,
and left-drag moves windows. Click a window to return to it.

## Everyday behavior

- **Input:** Caps Lock is another Ctrl. Mouse and touchpad use natural scrolling;
  touchpad scrolling runs at half speed.
- **Docking:** connecting this Studio Display disables the laptop panel;
  unplugging it restores the panel. Scales are 2.25 (5K external) and 1.55 (laptop).
  Kanshi manages this in Niri. The spare MST tile is disabled on DP-2; review
  that connector assumption when changing cables, docks, or monitors.
- **Sleep:** in Niri, idle locks after 10 minutes, blanks screens after 11, and
  suspends after 30, subject to idle inhibitors. Lid close suspends unless docked;
  the session locks before sleep. Plasma has its own power settings.
- **Screenshots:** press Print, select an area, then Space to capture or Esc to
  cancel. Files go to `~/Pictures/Screenshots/`. Without a Print key, run
  `niri msg action screenshot`.
- **Wallpapers:** Noctalia's wallpaper picker browses the KDE collection in
  `~/Pictures/Wallpapers/KDE`, with high-resolution light/dark variants, rotating
  randomly every six hours. Open it
  with `noctalia msg panel-toggle wallpaper`.
- **Recording:** F9 opens Kooha, defaulting to MP4/H.264 at 60 fps
  (constant quality, CRF 17), with 192 kbps AAC audio when enabled. Captures retain
  their native resolution; higher resolution and frame rate mean larger files.
  Niri 26.04 carries the
  [shared-memory capture backport](https://github.com/niri-wm/niri/pull/1791).
  Kooha carries its upstream clock fix and an isolated PipeWire timestamp fix.
  Open recordings in **Haruna**, the default video player (MP4, WebM, MKV, and more).
- **Chrome:** both desktops use KWallet 6 for cookie encryption. After updating
  Chrome, use **Restart Chrome** in the launcher or run `restart-chrome` to reopen
  the browser and its running PWAs. `--dry-run` previews; `--restore` retries the
  saved app list. Separate work-browser data directories are excluded. Unsaved
  forms and incognito windows are not guaranteed to survive.
- **Session restore:** Niri remembers whether Chrome was open and its open PWAs
  every five seconds, then reopens them on your next login. Chrome restores its
  own tabs. Other apps and window positions are not restored. State is in
  `~/.local/state/chrome-session/session.json`; stop `chrome-session.service`
  before deleting it to reset. This is not a backup of unsaved work.

## Hardware and services

**GeForce NOW** is the official NVIDIA Linux Flatpak. Open it from the launcher
and sign in to NVIDIA. `nix-flatpak` manages the user installation declaratively;
update it with `flatpak update --user com.nvidia.geforcenow`.

| Feature | Configuration |
| --- | --- |
| Boot and storage | UEFI/systemd-boot, encrypted ext4 root and swap, latest nixpkgs kernel |
| Intel hardware | Microcode, NPU, Xe graphics, hardware video acceleration, Dell Adaptive charging |
| Keyboard backlight | Dell firmware ambient-light mode; retains the input triggers and idle timeout |
| Speakers | Kernel GPIO backport prevents the camera driver claiming amplifier pins ([issue](https://github.com/thesofproject/sof/issues/11152)) |
| Built-in camera | Intel IPU7 hardware ISP with OV08X40 tuning; upright 3840×2160 V4L2 feed for browsers; Omarchy HAL patches |
| Studio Display | Bolt authorization and `asdbctl` brightness controls; enroll with `boltctl` once. Audio automatically prefers the display over laptop speakers while connected; a manual output selection overrides this. |
| Connectivity | NetworkManager, Bluetooth powered on at boot, Tailscale with tray autostart |

Home Manager supplies the workstation tools, including `gh`, 1Password, and
vanilla Codex/Claude launchers using personal authentication. The work jumphost
provides SOCKS5 at `127.0.0.1:1080`; `juspay-run`, `xyne-boxes`, and `pu` use it.
Zram and automatic garbage collection are enabled.

**Kolu starts at boot**, before login. Access it at
[http://gossamer:7692](http://gossamer:7692) or privately over Tailscale at
[https://gossamer.rooster-blues.ts.net](https://gossamer.rooster-blues.ts.net).
Remote HTTP is permitted only through Tailscale; Serve provides HTTPS, not Funnel.

## Where to change things

| Location | Owns |
| --- | --- |
| `default.nix` | Host composition and workstation apps |
| `configuration.nix`, `hardware-configuration.nix` | Base system, boot, disks, state version |
| `audio.nix` | Shared PipeWire audio setup; output preferences live with each device |
| `geforce-now.nix` | Flatpak support and official GeForce NOW installation |
| `dell-xps-16.nix`, `camera.nix`, `apple-studio-display.nix` | Hardware drivers and device workarounds |
| `desktop/default.nix` | Session composition and login screen |
| `desktop/plasma.nix`, `desktop/niri.nix`, `desktop/noctalia.nix` | Desktop-specific settings and controls |
| `desktop/input-preferences.nix`, `desktop/displays.nix`, `desktop/power.nix` | Input preferences, monitor profiles, sleep policy |
| `desktop/keyring.nix`, `chrome/` | Wallet integration, Chrome settings, restart and login restoration |
| `desktop/video.nix`, `desktop/recording.nix` | Video player, file associations, recording fixes |
| `tailscale.nix` | Tailscale, Kolu access, HTTPS, tray |

## Apply or reuse

From the repository root:

```sh
nix develop -c just activate gossamer
```

Most settings apply immediately. Log out/in after replacing Niri; reboot after
kernel changes. To build without activating:

```sh
nix build .#nixosConfigurations.gossamer.config.system.build.toplevel --no-link
```

For another laptop, generate your own `hardware-configuration.nix`, replace the
encrypted-swap UUID in `configuration.nix`, and keep your original
`system.stateVersion`. Review personal accounts, work services, Tailscale names,
and monitor identities before reusing this configuration.
