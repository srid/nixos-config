default:
    @just --list

# Activate local configuration
[group('main')]
activate:
    nix run

# Deploy host 'immediacy'
[group('main')]
deploy:
    nix run . immediacy

# Format the nix source tree
fmt:
    treefmt
