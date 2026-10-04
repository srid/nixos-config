default:
    @just --list

# Incus container lifecycle, parametrized by container name
# (e.g. `just incus deploy sheetal-codex`).
mod incus 'modules/nixos/linux/incus/mod.just'

# K3s app operations (e.g. `just apps olai shell`).
mod apps 'k8s/apps/mod.just'

# Main commands
# --------------------------------------------------------------------------------------------------

# Activate the given host or home environment
[group('main')]
activate host="":
    #!/usr/bin/env bash
    set -euo pipefail
    # macOS login shells default to 256 FDs. Nix's github: tarball-cache
    # opens one fd per member (olai, kolu) and dies with "Too many open files".
    if [ "$(ulimit -n)" -lt 65536 ] 2>/dev/null; then
      ulimit -n 65536 2>/dev/null || ulimit -n 10240 || true
    fi
    nix flake lock
    local_host=$(hostname -s)
    if [ -z "{{ host }}" ]; then
        if [ -f ./configurations/home/$USER@$HOSTNAME.nix ]; then
            echo "Activating home env $USER@$HOSTNAME ..."
            nix run . $USER@$HOSTNAME
        else
            echo "Activating system env $HOSTNAME ..."
            nix run . $HOSTNAME
        fi
    else
        if [ -f ./configurations/home/$USER@{{ host }}.nix ]; then
            if [ "{{ host }}" = "$local_host" ]; then
                echo "Activating home env $USER@{{ host }} ..."
                nix run . $USER@{{ host }}
            else
                echo "Deploying home env $USER@{{ host }} ..."
                # nixos-unified's remote home path SSHes a bare `nix run` and
                # never raises the fd limit. zest ssh sessions start at 256.
                flake=$(nix flake metadata --json --no-write-lock-file . | jq -r .path)
                ssh_target="$USER@{{ host }}"
                echo ">>> nix copy $flake --to ssh-ng://$ssh_target"
                nix --extra-experimental-features "nix-command flakes" copy "$flake" --to "ssh-ng://$ssh_target"
                echo ">>> ssh $ssh_target (ulimit + activate $USER@{{ host }})"
                ssh "$ssh_target" "ulimit -n 65536 2>/dev/null || ulimit -n 10240 || true; nix --extra-experimental-features 'nix-command flakes' run $flake#activate -- $USER@{{ host }}"
            fi
        else
            echo "Deploying to {{ host }} ..."
            nix run . {{ host }}
        fi
    fi

# Update primary flame inputs
[group('main')]
update:
    nix run .#update

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
