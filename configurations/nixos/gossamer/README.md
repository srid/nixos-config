# Gossamer — Dell XPS 16 (2026)

**XPS 16 DA16260**, Intel, x86_64, running NixOS with KDE Plasma 6.

- Uses systemd-boot (UEFI) and `pkgs.linuxPackages_latest`.
- Uses encrypted ext4 root, encrypted swap, and an EFI partition.
- Enables Intel microcode and NPU support.
- `camera.nix` uses Intel's IPU7 hardware image processor and OV08X40 sensor
  tuning, with pinned HAL patches from Omarchy for the Linux 7.2 CVS bridge.
  It exposes an upright 4K (3840×2160) V4L2 camera to browsers through
  `v4l2-relayd`; the competing libcamera software ISP is disabled.
- Uses `nixos-hardware`'s Intel graphics support with Xe and hardware video
  acceleration. Dell Adaptive charging adjusts battery charging to usage.
- `input.nix` makes Caps Lock an additional Ctrl and enables natural scrolling
  for mice and touchpads, including KDE Wayland defaults.
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
  `tailscale systray` app starting automatically at KDE login.
  Kolu is available at `http://gossamer:7692` locally and over Tailscale MagicDNS,
  or at `http://100.94.142.87:7692` using this laptop's Tailscale IP. It listens
  on all IPv4 addresses; the firewall allows remote access only on `tailscale0`.
  Tailscale Serve also provides `https://gossamer.rooster-blues.ts.net` privately
  within the tailnet; Funnel is not enabled.
  Tailscale settings and the tray autostart live in `tailscale.nix`.

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
