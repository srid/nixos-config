# Incus container lifecycle, parametrized by container name. Containers
# are `configurations/nixos/<name>` entries in this flake; see ./README.md.
# Run these on the incus host (naiveintent), inside the repo devshell:
#
#   just incus init <name>       # once: create the container
#   just incus deploy <name>     # first deploy and every config change
#   just incus tailscale <name>  # once: join tailnet + start serving
#   just incus shell <name>      # break-glass root shell

IMAGE := "images:nixos/unstable"

# Module recipes default to running in this directory; the flake ref in
# `deploy` wants the repo root.
set working-directory := '../../../..'

default:
    @just --list incus

# The host's default profile provides security.nesting, /dev/net/tun
# and the /host-nix-cache deploy mount.
# Create the <name> container (once).
init name:
    sudo incus launch {{ IMAGE }} {{ name }}

# No SSH: the closure travels via the host binary cache mounted
# read-only inside the container (see ./README.md).
# Build <name>'s NixOS closure and switch the container to it.
deploy name:
    #!/usr/bin/env bash
    set -euo pipefail
    toplevel=$(nix build --no-link --print-out-paths \
      .#nixosConfigurations.{{ name }}.config.system.build.toplevel)
    sudo nix copy --to 'file:///var/cache/incus-nix?compression=zstd' "$toplevel"
    sudo incus exec {{ name }} -- nix --extra-experimental-features nix-command \
      copy --no-check-sigs --from file:///host-nix-cache "$toplevel"
    sudo incus exec {{ name }} -- nix-env -p /nix/var/nix/profiles/system --set "$toplevel"
    sudo incus exec {{ name }} -- "$toplevel/bin/switch-to-configuration" switch

# Runs once; login and serve config persist in the container's
# /var/lib/tailscale. The served port is the container's declared
# `incus.servePort` (see guest.nix).
# Join <name> to the tailnet (browser auth) and start tailscale serve.
tailscale name:
    #!/usr/bin/env bash
    set -euo pipefail
    port=$(nix eval --raw --apply toString .#nixosConfigurations.{{ name }}.config.incus.servePort)
    [ -n "$port" ] || { echo "{{ name }} does not set incus.servePort"; exit 1; }
    # --hostname pins the tailnet node name: the kernel hostname can
    # still be the image's ("nixos") on first login after deploy.
    sudo incus exec {{ name }} -- tailscale up --hostname={{ name }}
    sudo incus exec {{ name }} -- tailscale serve --bg localhost:"$port"

# Root shell inside <name>.
shell name:
    sudo incus exec {{ name }} -- bash
