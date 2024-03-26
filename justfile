default:
    @just --list

fmt:
    treefmt

# Deploy to github-runner VM
github-runner:
    colmena apply --build-on-target
