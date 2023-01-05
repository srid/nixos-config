This repository contains the Nix / NixOS configuration for all of my systems. Start from `flakes.nix` (see [Flakes](https://nixos.wiki/wiki/Flakes)).

## Setup

### NixOS Linux

- Install NixOS
  - Hetzner dedicated from Linux Rescue system: https://github.com/serokell/nixos-install-scripts/pull/1#pullrequestreview-746593205
  - Digital Ocean: https://github.com/elitak/nixos-infect
  - X1 Carbon: https://srid.ca/x1c7-install
  - Windows (via WSL): https://github.com/nix-community/NixOS-WSL
- Clone this repo at `/etc/nixos`
- Edit `flake.nix` to use your system hostname in the `nixosConfigurations` set
- Edit `users/config.nix` to contain your users
- Run `nix develop -c , activate`. That's it. Re-open your terminal.

### macOS

- [Install Nix](https://nixos.org/download.html#nix-install-macos) (must be multi-user)
- Install [nix-darwin](https://github.com/LnL7/nix-darwin) 
    - This will create a `~/.nixpkgs/darwin-configuration.nix`, but we do not need that. 
- Clone this repo anywhere
- Edit `users/config.nix` to contain your users
- Run `nix develop -c , activate`.[^cleanup] That's it. Re-open your terminal.

[^cleanup]: You might have to `rm -rf /etc/nix/nix.conf`, so our flake.nix can do its thing.

## Directory layout 

- `home`: home-manager config (shared between Linux and macOS)
- `nixos`: nixos modules for Linux
- `nix-darwin`: nix-darwin modules for macOS
- `users`: user information
- `secrets`: agenix secrets (encrypted using ssh keys)
- `systems`: top-level configuration.nix('ish) for various systems

## Tips

- Run `,` in `nix develop` shell (tip: direnv better) to see available scripts.
- To update NixOS (and other inputs) run `nix flake update`
  - You may also update a subset of inputs, e.g.
      ```sh-session
      nix flake lock --update-input nixpkgs --update-input darwin --update-input home-manager
      # Also, in the dev shell: , update-primary
      ```
- To free up disk space,
    ```sh-session
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
    sudo nixos-rebuild boot
    ```
- To autoformat the project tree using nixpkgs-fmt, run `nix fmt`.
