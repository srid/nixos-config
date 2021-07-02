This repository contains the Nix / NixOS configuration for all of my systems. Start from `flakes.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)) if you are looking for NixOS configuration. Start from `home.nix` if you are looking for non-NixOS Nix configuration (eg: on macOS).

- `home.nix`: Only install things that are needed in all platforms (VMs, VPS, WSL2, etc.)
- `flake.nix`: Install things I need natively on NixOS desktop & laptop computers

VSCode note: <kbd>Ctrl+Shift+B</kbd> will run `sudo nixos-rebuild switch`.