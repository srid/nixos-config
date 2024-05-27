default:
    @just --list

# Activate local configuration
[group('main')]
activate:
    nix run

# Format the nix source tree
fmt:
    treefmt

# Deploy to all remote machines
deploy:
    colmena apply --build-on-target

# Deploy to github-runner VM
[group('github-runner')]
gr-deploy:
    colmena apply --build-on-target --on github-runner

# Re-animate the VM that was suspended until now.
[group('github-runner')]
gr-animate:
    colmena upload-keys
    ssh -t github-runner "sudo systemctl restart --all github-runner-*"

[group('github-runner')]
gr-inspect:
    ssh -t github-runner "sudo systemctl status --all github-runner-*"

[group('github-runner')]
gr-ssh:
    ssh -t github-runner