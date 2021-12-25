This repository contains the Nix / NixOS configuration for all of my systems. Start from `flakes.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)).

- `home.nix`: Only install things that are needed in all platforms (VMs, VPS, WSL2, etc.)
- `flake.nix`: Install things I need natively on NixOS desktop & laptop computers

VSCode note: <kbd>Ctrl+Shift+B</kbd> will run effectuate the new configuration (by running `make`).


## Platforms

### NixOS

```
make nixos
```

### macOS 

```
make darwin
```

### Other Linux distro (home-manager)

TODO: This section needs an update.

First time run,

```
make h0
ln -s /path/to/here ~/.config/nixpkgs  # Why? See Makefile
```

Afterwards, feel free to use `home-manager switch` (or `make`).

## Install notes

- Hetzner dedicated from Linux Rescue system: https://github.com/serokell/nixos-install-scripts/pull/1#pullrequestreview-746593205
- Digital Ocean: https://github.com/elitak/nixos-infect
- X1 Carbon: https://www.srid.ca/x1c7-install
