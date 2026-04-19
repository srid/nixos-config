# Incus

This module turns on [Incus](https://linuxcontainers.org/incus/) with a
bridged network (`incusbr0`), a `dir` storage pool, and the web UI. The
host's user is added to `incus` and `incus-admin`. Preseed is declarative
— the bridge, profile, and pool come up on first boot without
`incus admin init`.

## After the first activation

Log out and back in. The `users.users.<you>.extraGroups` change lands in
`/etc/group` at activation but your shell still has the old groups.
Check with `id`. If you don't see `incus-admin`, you haven't relogged.

Then:

```sh
incus launch images:nixos/unstable demo
incus list
incus exec demo -- bash
```

That's the whole smoke test. If it works, you're done.

## Containers vs. VMs

Same command, one flag:

```sh
incus launch images:nixos/unstable demo          # container (fast, shared kernel)
incus launch images:nixos/unstable demo --vm     # VM (slower boot, full isolation)
```

Containers share the host kernel and boot in a second or two. VMs need
`/dev/kvm` and take ~10s to boot, but run a different kernel. Pick the
container unless you need the kernel boundary.

The `images:` remote ships community NixOS builds for `unstable`,
`25.05`, `24.11` on `amd64` and `arm64`. They're minimal — SSH on, no
flakes, no home-manager. Customize post-launch with `incus exec` or
rebuild from a flake inside the instance.

## The web UI

`ui.enable = true` bundles the UI assets but doesn't open a socket.
Configure the listener on each host that imports this module:

```nix
virtualisation.incus.preseed.config."core.https_address" = "<ip>:8443";
```

Binding to a Tailscale IP (e.g. `100.x.y.z:8443`) is the easy win: no
firewall change needed because `services.tailscale.enable` already
trusts `tailscale0`. Binding to `0.0.0.0:8443` needs `8443` added to
`networking.firewall.allowedTCPPorts`.

First time you hit the UI, the browser has no client cert. Trust the
self-signed server cert, then add your browser as a trusted client:

```sh
# On the host, grab the UI's fingerprint from the browser, then:
incus config trust add-certificate --name my-browser
```

Or generate one via CLI and import into the browser. The UI walks you
through it.

## When it breaks

**"permission denied" on `/var/lib/incus/unix.socket`** — your shell
isn't in `incus-admin` yet. Log out and back in, or `sudo -u <you> -i`
from another session.

**Containers won't get an IP.** The preseed bridge didn't come up.
Check `incus network list` — `incusbr0` should be `CREATED` with an
IPv4/IPv6 range. If it's missing, `systemctl status incus-preseed` will
show the error.

**`user-1000` project weirdness.** Incus auto-created a per-user
project and you're stuck in it. Get out:

```sh
incus project switch default
```

**Nuclear reset.** When the daemon state is wedged past saving:

```sh
sudo systemctl stop incus incus.socket
sudo rm -rf /var/lib/lx* /var/lib/incus/
sudo systemctl start incus
```

Then re-activate the NixOS config so the preseed runs again. All
instances and images are lost — don't do this casually.

## Why a `dir` storage pool

The preseed picks `driver = "dir"` because it works anywhere without
extra setup. It's also the slowest option and doesn't support instance
snapshots. If you start running more than a handful of instances,
switch to `zfs` or `btrfs` — edit the preseed and reset the pool
(containers on the old pool have to be re-created).
