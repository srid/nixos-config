default:
    @just --list

# Activate local configuration
activate:
    nix run

# Format the nix source tree
fmt:
    treefmt

# Deploy to github-runner VM
gr-deploy:
    colmena apply --build-on-target

# Re-animate the VM that was suspended until now.
gr-animate:
    colmena upload-keys
    ssh -t github-runner "sudo systemctl restart --all github-runner-*"
