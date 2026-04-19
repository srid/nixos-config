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

incus launch images:nixos/unstable demo --vm \   # VM (full isolation)
  -c security.secureboot=false \
  -c limits.memory=8GiB \
  -c limits.cpu=4 \
  -d root,size=50GiB
```

Containers share the host kernel and boot in a second or two. VMs need
`/dev/kvm` and take ~10s to boot, but run a different kernel. Pick the
container unless you need the kernel boundary.

Why each VM flag:
- `security.secureboot=false` — community NixOS images aren't signed
  for UEFI secure boot, so incus refuses to start them unless the check
  is off. A signed image would make this unneeded; none ships in the
  `images:` remote today.
- `limits.memory=8GiB` — the incus default is too small for
  `nixos-rebuild switch` inside the VM. Symptoms of a too-small VM:
  builds die partway with no clear error, or `incus console` drops with
  `websocket: close 1006 (abnormal closure)` when the guest OOMs.
- `limits.cpu=4` — optional, but `nixos-rebuild` is CPU-bound on eval.
- `-d root,size=50GiB` — the community image defaults to ~10 GiB.
  That's enough to boot and not much else; one `nix run` that fetches
  nixpkgs can fill it. Symptom: `error: ... No space left on device`
  partway through an eval. Resizing a running VM's root is fragile, so
  pick a generous size at launch.

The `images:` remote ships community NixOS builds for `unstable`,
`25.05`, `24.11` on `amd64` and `arm64`. They're minimal — no users,
no flakes, no home-manager. Customize post-launch with `incus exec` or
rebuild from a flake inside the instance.

## Getting a shell

Use `incus exec` — it routes through the incus agent inside the
instance, so it works with zero setup on a fresh image:

```sh
incus exec demo -- bash
```

No SSH keys, no networking concerns, no users. If you specifically need
real SSH (e.g. for `rsync`, editor remotes), push your pubkey into
`/root/.ssh/authorized_keys` with `incus file push` and SSH to the IP
shown in `incus list`.

## Configuring the guest

The community image has its own `/etc/nixos/configuration.nix` — it's
the guest's config, nothing to do with this host flake. Two edits you'll
almost always want on a fresh VM:

```nix
{ pkgs, ... }:
{
  # Flakes + the new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Whatever ports your services listen on
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
```

Apply with `sudo nixos-rebuild switch`. If the build dies mid-way or
`incus exec` starts hanging afterward, the VM is under-provisioned —
relaunch with higher `limits.memory` (see the VM section above).

## Running and exposing a service

Say you want to host something on port 8080 inside the instance. Three
layers have to cooperate, and each has its own failure mode.

**1. Bind to the right interface.** Servers that default to `127.0.0.1`
won't be reachable from the host no matter what else you do. Make sure
yours is listening on `0.0.0.0:8080` (or the bridge IP). From inside:

```sh
ss -tlnp | grep 8080
```

**2. Open the instance's firewall.** NixOS community images ship with
`networking.firewall.enable = true` and no ports open. Symptom: `curl`
from *inside* the instance works, `curl` from the host hangs. Fix in
`/etc/nixos/configuration.nix`:

```nix
networking.firewall.allowedTCPPorts = [ 8080 ];
```

Then `sudo nixos-rebuild switch`. The host can now hit the instance on
its `incusbr0` IP (from `incus list`).

**3. Publish to the LAN (optional).** The `incusbr0` IPs aren't
reachable outside the host. To forward a host port into an instance:

```sh
incus config device add myvm web proxy \
  listen=tcp:0.0.0.0:8080 \
  connect=tcp:127.0.0.1:8080
```

Now anything that reaches the host on `:8080` gets proxied in. Remember
to open `8080` in the *host's* `networking.firewall.allowedTCPPorts`
too — or bind the proxy to a Tailscale IP and skip the firewall edit.

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
