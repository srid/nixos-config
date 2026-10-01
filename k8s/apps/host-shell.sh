#!/usr/bin/env bash
# Temporarily expose a PVC subdirectory to a host-user shell. The private mount
# namespace releases the bind mount on exit without needing another sudo prompt.
set -euo pipefail

# Re-enter from a file, not stdin: the interactive shell needs the original TTY.
if [[ "${1:-}" == --mounted ]]; then
    source=$2
    mount_dir=$3
    user=$4
    group=$5
    user_home=$6
    user_shell=$7
    runtime_dir=$8
    mount --bind "$source" "$mount_dir"
    trap 'umount "$mount_dir"' EXIT
    echo "Live app data mounted at $mount_dir; exit the shell to unmount."
    # Drop privileges without a second sudo PTY or environment reset. The root
    # supervisor stays outside the mount so it can unmount after the shell exits.
    setpriv --reuid "$user" --regid "$group" --init-groups \
        env HOME="$user_home" USER="$user" LOGNAME="$user" \
        SHELL="$user_shell" XDG_RUNTIME_DIR="$runtime_dir" \
        bash -c 'cd "$1" && exec "$2" -i' -- "$mount_dir" "$user_shell"
    exit
fi

namespace=$1
claim=$2
subdirectory=$3
volume=$(sudo k3s kubectl -n "$namespace" get pvc "$claim" -o jsonpath='{.spec.volumeName}')
source=$(sudo k3s kubectl get pv "$volume" -o jsonpath='{.spec.local.path}{.spec.hostPath.path}')
if [[ "$source" != /* ]]; then
    echo 'Expected a local volume on this K3s host.' >&2
    exit 1
fi

mount_dir=$(mktemp -d "${TMPDIR:-/tmp}/${claim}.XXXXXX")
trap 'rmdir "$mount_dir"' EXIT
sudo unshare --mount --propagation private bash "$(realpath "$0")" --mounted \
    "$source/$subdirectory" "$mount_dir" "$(id -un)" "$(id -g)" \
    "$HOME" "${SHELL:-/bin/sh}" "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
