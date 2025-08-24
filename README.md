[![AGPL](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://en.wikipedia.org/wiki/Affero_General_Public_License)
[![project chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://nixos.zulipchat.com/#narrow/stream/413948-nixos)
[![Naiveté Compass of Mood](https://img.shields.io/badge/naïve-FF10F0)](https://compass.naivete.me/ "This project follows the 'Naiveté Compass of Mood'")

This repository contains the Nix / NixOS configuration for all of my systems. See [nixos-unified](https://nixos-unified.org)—specifically [nixos-unified-template](https://github.com/juspay/nixos-unified-template)—if you wish to create your own configuration from scratch.

## Setup

To use this repository as base configuration for your new machine running:

### NixOS Linux

> [!TIP]
> For a general tutorial, see https://nixos.asia/en/nixos-install-flake

- Install NixOS
  - Hetzner dedicated from Linux Rescue system: https://github.com/numtide/nixos-anywhere (see [blog post](https://galowicz.de/2023/04/05/single-command-server-bootstrap/); example PR: https://github.com/srid/nixos-config/pull/35 where I had to configure networking manually)
    - Copy from existing configuration (eg: ax41.nix)
    - Make networking configuration changes.
    - Run nixos-anywhere from a Linux system, targetting `root@<ip>`
    - Wait for reboot; `ssh srid@<ip>`; profit!
  - Digital Ocean
    - Legacy/manual approach: [nixos-infect](https://github.com/elitak/nixos-infect)
    - Modern/automate approach: Custom image + colerama; cf. [Zulip](https://nixos.zulipchat.com/#narrow/stream/413948-nixos/topic/Deploying.20to.20DigitalOcean) and [example](https://github.com/fpindia/fpindia-chat)
  - X1 Carbon: https://srid.ca/x1c7-install
  - Windows (via WSL): https://github.com/nix-community/NixOS-WSL
- Clone this repo anywhere
- Rename `./configurations/nixos/??.nix` to match your current system hostname
- Edit `config.nix` to set your primary user information
- Run `nix run`. That's it. Re-open your terminal.

### macOS

- [Install Nix](https://nixos.asia/en/install)
- Clone this repo anywhere
- Rename `./configurations/darwin/??.nix` to match your current system hostname
- Edit `config.nix` to set your primary user information
- Run `nix run`.[^cleanup] That's it. Re-open your terminal.

[^cleanup]: You might have to `rm -rf /etc/nix/nix.conf`, so our flake.nix can do its thing.

## Architecture

Start from `flake.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)). [`flake-parts`](https://flake.parts/) is used as the module system.

### Directory layout

>[!TIP]
> See `flake-module.nix` for autowiring of flake outputs based on this directory structure.

| Path | Corresponding flake output |
| -- | -- |
| `./configurations/{nixos,darwin,home}/foo.nix` |  `{nixos,darwin,home}Configurations.foo` |
| `./mdules/{nixos,darwin,home,flake-parts}/foo.nix` | `{nixos,darwin,home,flake}Modules.foo` |
| `./overlays/foo.nix` | `overlays.foo` |
| `./packages` | N/A (Nix packages) |
| `./secrets` | N/A (agenix data) |

## Tips

- To update NixOS (and other inputs) run `nix flake update`
  - You may also update only primary inputs:
    ```sh
    # nix run .#update
    ```
- To free up disk space,
  ```sh-session
  sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
  sudo nixos-rebuild boot
  ```
- To autoformat the project tree using nixpkgs-fmt, run `just lint` in Nix devShell.
- To build all flake outputs (locally or in CI), run `nix run nixpkgs#omnix ci`
- For secrets management, I use [agenix](https://github.com/ryantm/agenix), because it works with SSH keys, and functions well on macOS and NixOS.

## Discussion

If you wish to discuss this config, [join the NixOS Asia community](https://nixos.asia/en/#community).
