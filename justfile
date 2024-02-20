default:
    @just --list

here:
    nixos-rebuild switch --fast --flake .#here --target-host $USER@here --build-host $USER@here --use-remote-sudo