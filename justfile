default:
    @just --list

# Remote deploy to a host
remote host='here':
    nixos-rebuild switch --fast --use-remote-sudo \
        --flake .#{{host}} \
        --target-host $USER@{{host}} \
        --build-host $USER@{{host}}
