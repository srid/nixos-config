default:
    @just --list

# Activate local configuration
activate:
    nix run

# Format the nix source tree
fmt:
    treefmt

# Deploy to all remote machines
deploy:
    colmena apply --build-on-target

# Deploy to github-runner VM
[group('gr')]
gr-deploy:
    colmena apply --build-on-target --on github-runner

# Re-animate the VM that was suspended until now.
[group('gr')]
gr-animate:
    colmena upload-keys
    ssh -t github-runner "sudo systemctl restart --all github-runner-*"

[group('gr')]
gr-inspect:
    ssh -t github-runner "sudo systemctl status --all github-runner-*"

[group('gr')]
gr-ssh:
    ssh -t github-runner