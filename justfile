default:
    @just --list

# Activate local configuration
[group('main')]
activate:
    nix run

# Deploy host 'immediacy'
[group('main')]
deploy:
    nix run . host immediacy

# Format the nix source tree
fmt:
    treefmt
