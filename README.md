This repository contains the Nix / NixOS configuration for all of my systems. Start from `flakes.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)).

## Platforms

### NixOS

```sh-session
make nixos  # Or, just `make`
```

### macOS 

```sh-session
make darwin # Or, just `make`
```

## Install notes

- Hetzner dedicated from Linux Rescue system: https://github.com/serokell/nixos-install-scripts/pull/1#pullrequestreview-746593205
- Digital Ocean: https://github.com/elitak/nixos-infect
- X1 Carbon: https://www.srid.ca/x1c7-install
- macOS: 
    - Install Nix normally (multi-user)
    - Install [nix-darwin](https://github.com/LnL7/nix-darwin) 
        - This will create a `~/.nixpkgs/darwin-configuration.nix`, but we do not need that. 
    - Edit `flake.nix` and add your Mac's [hostname](https://support.apple.com/en-ca/guide/mac-help/mchlp2322/mac) in the `darwinConfigurations` set.
    - Run `make`.[^cleanup] That's it. Re-open your shell.

[^cleanup]: You might have to `rm -rf /etc/nix/nix.conf`, so our flake.nix can do its thing.
