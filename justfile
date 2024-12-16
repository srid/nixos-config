default:
    @just --list

# Activate local configuration
[group('main')]
local:
    nix run

# Run this before `nix run` to build the current configuration
[group('main')]
nom:
    , nom build --no-link .#nixosConfigurations.vixen.config.system.build.toplevel

# Deploy to Beelink
[group('deploy')]
pureintent:
    nix run . pureintent

# Deploy to nginx gate
[group('deploy')]
gate:
    nix run . gate

# Format the nix source tree
fmt:
    pre-commit run --all-files

# https://discourse.nixos.org/t/why-doesnt-nix-collect-garbage-remove-old-generations-from-efi-menu/17592/4
fuckboot:
    sudo nix-collect-garbage -d
    sudo /run/current-system/bin/switch-to-configuration boot