default:
    @just --list

# Main commands
# --------------------------------------------------------------------------------------------------

# Activate local configuration (home if exists, else system)
[group('main')]
activate:
    @if [ -f ./configurations/home/$USER@$HOSTNAME.nix ]; then \
        just deploy $USER@$HOSTNAME; \
    else \
        just deploy $HOSTNAME; \
    fi

# Update primary flame inputs
[group('main')]
update:
    nix run .#update

# Deploy to a given host
[group('main')]
deploy host:
    @echo "Deploying to {{host}} ..."
    @nix run . {{host}}

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