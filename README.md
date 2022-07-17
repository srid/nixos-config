This repository contains the Nix / NixOS configuration for all of my systems. Start from `flakes.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)).

To build,

```sh
# First, edit nixosConfigurations or darwinConfigurations in flake.nix to add
# your system's hostname. And then change `userName` to your username.
make
```

## Install notes

- NixOS Linux
  - Install NixOS
    - Hetzner dedicated from Linux Rescue system: https://github.com/serokell/nixos-install-scripts/pull/1#pullrequestreview-746593205
    - Digital Ocean: https://github.com/elitak/nixos-infect
    - X1 Carbon: https://www.srid.ca/x1c7-install
    - Windows (via WSL): https://github.com/nix-community/NixOS-WSL
  - Clone this repo at `/etc/nixos`
  - Edit `flake.nix` and add your Linux's hostname in the `nixosConfigurations` set, as well as update `userName`.
  - Run `make`. That's it. Re-open your shell.
- macOS: 
    - Install Nix normally (multi-user)
    - Install [nix-darwin](https://github.com/LnL7/nix-darwin) 
        - This will create a `~/.nixpkgs/darwin-configuration.nix`, but we do not need that. 
    - Clone this repo anywhere
    - Edit `flake.nix` and add your Mac's [hostname](https://support.apple.com/en-ca/guide/mac-help/mchlp2322/mac) in the `darwinConfigurations` set, as well update `userName`.
    - Run `make`.[^cleanup] That's it. Re-open your shell.

[^cleanup]: You might have to `rm -rf /etc/nix/nix.conf`, so our flake.nix can do its thing.

## Directory layout 

- `home`: home-manager config
- `nixos`: nixos config (includes nix-darwin)
- `systems`: top-level configuration.nix('ish) for various kinds of system

## Tips

- To update NixOS (and other inputs) run `nix flake update`
