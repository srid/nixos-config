# Run on the K3s host. Importing apps supply namespace, deployment, and container.
# k3s is a host tool; these commands do not need a Nix devShell.

# List this app's commands.
[default]
default:
    @just --list apps {{deployment}}

# Open an interactive shell as the app user, starting in its home directory.
shell:
    sudo k3s kubectl -n {{namespace}} exec -it deployment/{{deployment}} -c {{container}} -- /bin/sh -c 'cd "$HOME" && exec /bin/sh'

# Follow app logs, including the last 100 lines.
logs:
    sudo k3s kubectl -n {{namespace}} logs -f deployment/{{deployment}} -c {{container}} --tail=100

# Show workloads, routing, storage, and secret synchronization in the app namespace.
status:
    sudo k3s kubectl -n {{namespace}} get deployments,pods,services,ingresses,pvc,externalsecrets

# Restart the app to reload credentials, then wait for it to become ready.
restart:
    sudo k3s kubectl -n {{namespace}} rollout restart deployment/{{deployment}}
    sudo k3s kubectl -n {{namespace}} rollout status deployment/{{deployment}} --timeout=120s
