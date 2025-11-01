default:
    @just --list

# Main commands
# --------------------------------------------------------------------------------------------------

# Activate the given host or home environment
[group('main')]
activate host="":
    nix flake lock
    @if [ -z "{{host}}" ]; then \
        if [ -f ./configurations/home/$USER@$HOSTNAME.nix ]; then \
            echo "Activating home env $USER@$HOSTNAME ..."; \
            nix run . $USER@$HOSTNAME; \
        else \
            echo "Activating system env $HOSTNAME ..."; \
            nix run . $HOSTNAME; \
        fi \
    else \
        echo "Deploying to {{host}} ..."; \
        nix run . {{host}}; \
    fi

# Update primary flame inputs
[group('main')]
update:
    nix run .#update

# Run all pre-commit hooks on all files
[group('main')]
lint:
    pre-commit run --all-files


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
