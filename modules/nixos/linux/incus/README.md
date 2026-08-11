# Incus

Each service runs in its own incus container, and each container is an
ordinary `configurations/nixos/<name>` entry in this flake — built and
evaluated like any other host. Isolation comes from Tailscale, not port
plumbing: every container joins the tailnet as its own node, binds its
service to `127.0.0.1`, and publishes it with `tailscale serve` at
`https://<name>.<tailnet>.ts.net`. There are no proxy devices, no host
firewall ports, and no SSH.

Two modules:

- `host.nix` — the incus daemon, imported by the host (naiveintent).
  Declarative preseed: `incusbr0` bridge, `dir` storage pool, and a
  default profile that gives every container `security.nesting`,
  `/dev/net/tun` (for tailscaled), and a read-only mount of the deploy
  cache (below). No web UI, and no `incus-admin` group for the user —
  all incus commands go through `sudo`.
- `guest.nix` — imported by each container's configuration:
  `lxc-container.nix` plumbing, tailscale, no sshd, and the
  `incus.servePort` option (which loopback port `tailscale serve`
  publishes).

Lifecycle recipes live in `./mod.just`, registered as `mod incus` in
the top-level justfile and parametrized by container name.

## How deploys work

`nixos-rebuild --target-host` needs SSH; we don't run any. Instead the
container's `mod.just` deploy recipe, run **on the host**:

1. builds `.#nixosConfigurations.<name>...toplevel`;
2. `nix copy`-s the closure to `/var/cache/incus-nix` (a `file://`
   binary cache — incremental, only new paths are written);
3. `incus exec`-s the container to `nix copy` it in from
   `/host-nix-cache` (that same directory, mounted read-only by the
   default profile) and run `switch-to-configuration switch`.

The host's `/nix/store` is deliberately NOT shared with the guest: the
container keeps a complete copy of its closure in its own store.
(Bind-mounting the host store over the guest's would shadow the image's
own store paths — breaking the running system at bootstrap — and tie
the guest's lifetime to host GC.) So host GC can't break a container,
and the cache dir can be pruned freely.

## Container lifecycle

```sh
just incus init <name>       # once: incus launch (profile does the rest)
just incus deploy <name>     # first deploy and every config change
just incus tailscale <name>  # once: tailscale up (browser auth) + serve
just incus shell <name>      # break-glass root shell via incus exec
```

Tailscale login and `serve` config persist in the container's
`/var/lib/tailscale`, surviving reboots and deploys.

## Adding a new container

1. `mkdir configurations/nixos/<name>` with a `default.nix` that imports
   `guest.nix`, sets `networking.hostName` and `incus.servePort`, and
   configures the service bound to `127.0.0.1`. nixos-unified
   auto-wires it (see `configurations/nixos/myolai/` for the model).
2. `just incus init <name> && just incus deploy <name> && just incus
   tailscale <name>`.

## When it breaks

**Container gets no IP** — the preseed bridge didn't come up. Check
`sudo incus network list` (expect `incusbr0` CREATED) and
`systemctl status incus-preseed`.

**`tailscale up` fails with no tun device** — the container was created
before this profile existed. `sudo incus config device add <name> tun
unix-char source=/dev/net/tun path=/dev/net/tun` and restart it.

**Deploy fails reading `/host-nix-cache`** — same vintage problem:
`sudo incus config device add <name> nix-cache disk
source=/var/cache/incus-nix path=/host-nix-cache readonly=true`.

**Nuclear reset** (daemon state wedged; kills all containers):

```sh
sudo systemctl stop incus incus.socket
sudo rm -rf /var/lib/incus/
sudo systemctl start incus.socket
```

Then re-activate the host config so the preseed runs again.
