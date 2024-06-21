default:
    @just --list

# Activate local configuration
[group('main')]
activate:
    nix run

# Format the nix source tree
fmt:
    treefmt
