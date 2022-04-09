This repository contains the Nix / NixOS configuration for all of my systems. Start from `flakes.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)).

- `flake.nix`: Install things I need natively on NixOS or macOS systems.

VSCode note: <kbd>Ctrl+Shift+B</kbd> will run effectuate the new configuration (by running `make`).


## Platforms

### NixOS

```sh-session
make nixos
```

### macOS 

```sh-session
make darwin
```

## Install notes

- Hetzner dedicated from Linux Rescue system: https://github.com/serokell/nixos-install-scripts/pull/1#pullrequestreview-746593205
- Digital Ocean: https://github.com/elitak/nixos-infect
- X1 Carbon: https://www.srid.ca/x1c7-install
- macOS: https://github.com/LnL7/nix-darwin
