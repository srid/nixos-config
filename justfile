default:
    @just --list

fmt:
    treefmt

# Deploy to github-runner VM
github-runner:
    colmena apply --build-on-target

# Run this after editing .sops.yaml
sops-updatekeys:
    sops updatekeys secrets.json

# Edit or view the secrets
sops-edit:
    sops secrets.json
