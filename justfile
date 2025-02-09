default:
    @just --list

# Activate local configuration (Use `just nom local`)
[group('main')]
local:
    nix run

# Run this before `nix run` to build the current configuration
[group('main')]
nom:
    nom build --no-link .#nixosConfigurations.infinitude.config.system.build.toplevel

# Deploy to Beelink
[group('deploy')]
pureintent:
    nix run . pureintent

# Deploy to infinitude (mac)
[group('deploy')]
infinitude:
    nix run . infinitude

# Run all pre-commit hooks on all files
pca:
    pre-commit run --all-files

# https://discourse.nixos.org/t/why-doesnt-nix-collect-garbage-remove-old-generations-from-efi-menu/17592/4
fuckboot:
    sudo nix-collect-garbage -d
    sudo /run/current-system/bin/switch-to-configuration boot
