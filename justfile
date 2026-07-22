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
# Optional branch: `just kolu feat/foo` rewrites flake.nix kolu.url before updating.
[group('main')]
kolu branch="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -n "{{ branch }}" ]; then
      echo ">>> kolu branch: {{ branch }}"
      python3 -c '
    import pathlib, re, sys
    branch = sys.argv[1]
    path = pathlib.Path("flake.nix")
    text = path.read_text()
    new = f"kolu.url = \"github:juspay/kolu/{branch}\";"
    updated, n = re.subn(
        r"kolu\.url = \"github:juspay/kolu[^\"]*\";",
        new,
        text,
        count=1,
    )
    if n != 1:
        sys.exit("error: could not find unique kolu.url in flake.nix")
    path.write_text(updated)
    print(f"    flake.nix → {new}")
    ' "{{ branch }}"
    else
      echo ">>> kolu branch: (unchanged; flake lock update only)"
    fi
    just _kolu-update
    just _kolu-after-update

_kolu-update:
    nix flake update kolu drishti

[parallel]
_kolu-after-update: _kolu-activate-pureintent _kolu-activate-naiveintent _kolu-activate-local

_kolu-activate-pureintent:
    just activate pureintent

_kolu-activate-naiveintent:
    just activate naiveintent

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
