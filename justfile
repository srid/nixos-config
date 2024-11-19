default:
    @just --list

# Activate local configuration
[group('main')]
activate:
    nix run

# Deploy host 'pureintent'
[group('main')]
deploy:
    nix run . pureintent

# Format the nix source tree
fmt:
    pre-commit run --all-files
