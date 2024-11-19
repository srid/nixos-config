default:
    @just --list

# Activate local configuration
[group('main')]
local:
    nix run

# Deploy to Beelink
[group('deploy')]
pureintent:
    nix run . pureintent

# Deploy to nginx gate
[group('deploy')]
gate:
    nix run . gate

# Format the nix source tree
fmt:
    pre-commit run --all-files
