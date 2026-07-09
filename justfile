default:
    @just --list

# Per-host operational recipes. Namespaced via `mod` so each host's
# recipes live behind their own prefix (e.g. `just pureintent anywhen-deploy`).
mod pureintent 'configurations/nixos/pureintent/mod.just'

# Main commands
# --------------------------------------------------------------------------------------------------

# Activate the given host or home environment
[group('main')]
activate host="":
    nix flake lock
    @if [ -z "{{ host }}" ]; then \
        if [ -f ./configurations/home/$USER@$HOSTNAME.nix ]; then \
            echo "Activating home env $USER@$HOSTNAME ..."; \
            nix run . $USER@$HOSTNAME; \
        else \
            echo "Activating system env $HOSTNAME ..."; \
            nix run . $HOSTNAME; \
        fi \
    else \
        echo "Deploying to {{ host }} ..."; \
        nix run . {{ host }}; \
    fi

# Update primary flame inputs
[group('main')]
update:
    nix run .#update

# Update Kolu/Drishti, then build Kolu and activate target environments.
[group('main')]
kolu: _kolu-update && _kolu-after-update

_kolu-update:
    nix flake update kolu drishti

[parallel]
_kolu-after-update: _kolu-build _kolu-activate-pureintent _kolu-activate-local

_kolu-build:
    nix build --inputs-from . kolu

_kolu-activate-pureintent:
    just activate pureintent

_kolu-activate-local:
    just activate

# Misc commands
# --------------------------------------------------------------------------------------------------

# SSH to tart CM
[group('misc')]
tart-ssh:
    ssh $(tart ip nixos-vm)

# https://discourse.nixos.org/t/why-doesnt-nix-collect-garbage-remove-old-generations-from-efi-menu/17592/4
[group('misc')]
fuckboot:
    sudo nix-collect-garbage -d
    sudo /run/current-system/bin/switch-to-configuration boot
