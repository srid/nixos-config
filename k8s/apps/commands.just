# Importing apps supply host, namespace, deployment, and container. Commands
# run `k3s kubectl` on the app's host: directly when that is this machine,
# otherwise over SSH with a TTY (so `shell` and `logs -f` behave). k3s is a
# host tool; these commands do not need a Nix devShell.

set positional-arguments

# ssh joins its arguments with spaces and the remote login shell re-parses
# them, so a quoted `sh -c '…'` would fall apart there and its tail would run
# on the host instead of in the pod. Re-quote every argument for that shell.
[private]
kubectl *args:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{host}}" = "$(hostname -s)" ]; then
        exec sudo k3s kubectl "$@"
    else
        exec ssh -t {{host}} "$(printf '%q ' sudo k3s kubectl "$@")"
    fi

# List this app's commands.
[default]
default:
    @just --list apps {{deployment}}

# Open an interactive shell as the app user, starting in its home directory.
shell: (kubectl "-n" namespace "exec" "-it" ("deployment/" + deployment) "-c" container "--" "/bin/sh" "-c" 'cd "$HOME" && exec /bin/sh')

# Follow app logs, including the last 100 lines.
logs: (kubectl "-n" namespace "logs" "-f" ("deployment/" + deployment) "-c" container "--tail=100")

# Show workloads, routing, storage, and secret synchronization in the app namespace.
status: (kubectl "-n" namespace "get" "deployments,pods,services,ingresses,pvc,externalsecrets")

# Restart the app to reload credentials, then wait for it to become ready.
restart: (kubectl "-n" namespace "rollout" "restart" ("deployment/" + deployment)) (kubectl "-n" namespace "rollout" "status" ("deployment/" + deployment) "--timeout=120s")
