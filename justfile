default:
    @just --list

fmt:
    treefmt

# Remote deploy to a host
remote-deploy host='parallels-linux-builder':
    nixos-rebuild switch --fast --use-remote-sudo \
        --flake .#{{host}} \
        --target-host $USER@{{host}} \
        --build-host $USER@{{host}}

# First install on a remote machine
remote-install host='parallels-linux-builder':
    nix run github:nix-community/nixos-anywhere \
        -- \
        --build-on-remote \
        --flake .#{{host}} \
        root@{{host}}

# Run this after editing .sops.yaml
sops-updatekeys:
    sops updatekeys secrets.json

# Edit or view the secrets
sops-edit:
    sops secrets.json
