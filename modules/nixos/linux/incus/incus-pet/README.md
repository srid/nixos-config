# incus-pet

Per-app incus container CLI ("pet PaaS"). Takes a NixOS service flake,
materialises it into a dedicated incus container on the local host, and
exposes the service on a chosen `<listen-ip>:<host-port>` that proxies
to a fixed `8080` inside the container.

```
incus-pet deploy github:srid/anywhen --port 7700 --listen 100.122.32.106
incus-pet list
incus-pet rm anywhen
```

See `SKILL.md` for the agent-facing recipe; this README is for humans
running the CLI directly.

## Prerequisites

- The host runs the incus daemon (this repo's `modules/nixos/linux/incus`
  enables it).
- The operator's user is in the `incus-admin` group.
- An SSH key exists at `~/.ssh/id_ed25519.pub` (or `~/.ssh/id_rsa.pub`)
  that root inside the container will trust.
- The target flake ships `nixosModules.incus` (see `SKILL.md` Branch C
  for what that means, or the anywhen flake for a worked example).

## The deploy unit — what a flake must ship

```nix
# in the app's flake.nix outputs
nixosModules.incus = { config, lib, pkgs, ... }: {
  imports = [ self.nixosModules.default ];
  incus.container = {
    enable   = true;
    hostname = lib.mkDefault "anywhen";
  };
  system.stateVersion = "25.05";
  services.anywhen = {
    enable  = true;
    package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.default;
    host    = lib.mkDefault "0.0.0.0";
    port    = 8080;  # the incus-pet contract — fixed
  };
};
```

The CLI's marshaling flake imports this alongside `container.nix` (the
in-tree essentials) and runs `nixos-rebuild switch --target-host`
against the container.

## Network model — fixed inside, unique outside

This is the section worth reading twice.

### Inside the container

Every containerized service binds **the same port**: `8080`. This is a
convention, declared as a `readOnly` option (`incus.container.servicePort`)
in `container.nix`. App authors do not pick a port — they wire
`services.<app>.port = config.incus.container.servicePort` and move on.
Cross-app port collisions become impossible because there is only one
port to collide with, and each container has its own network namespace.

### Outside the container (the host)

The host runs an **incus proxy device** per container that translates a
unique `<listen-ip>:<host-port>` on the host into a connection to the
container's `127.0.0.1:8080`:

```
incus config device add <name> web proxy \
  listen=tcp:<listen-ip>:<host-port> \
  connect=tcp:127.0.0.1:8080
```

`incus-pet deploy` wires this for you idempotently. The `<host-port>`
and `<listen-ip>` are stored in container metadata
(`user.incus-pet.host-port`, `user.incus-pet.listen`) so re-running
`incus-pet deploy <flake-ref>` doesn't need the flags repeated.

### Picking a listen IP

`<listen-ip>` can be any address bound on the host. The three meaningful
choices:

| Listen IP        | Reach                | Firewall edit needed?                       |
|------------------|----------------------|---------------------------------------------|
| `0.0.0.0`        | Anyone who can route to this host's NIC | Yes — open `<host-port>` in `networking.firewall.allowedTCPPorts` |
| Host's LAN IP    | Same as above, scoped to that NIC       | Yes — same as above                          |
| Host's tailnet IP (e.g. `100.122.32.106`) | Tailnet only         | **No** — `tailscale0` is in `networking.firewall.trustedInterfaces` (see `configurations/nixos/pureintent/default.nix:78`), so traffic on that interface bypasses the host firewall |

For "internal apps on my box, reachable only from my tailnet" (the
common case), pick the tailscale IP. On a host where you always want
that, export the IP once:

```sh
# in your shell profile, or via environment.variables in the host config
export INCUS_PET_LISTEN=100.122.32.106
```

…and every `incus-pet deploy` binds there automatically.

### What the container's own firewall does

`container.nix` opens `8080` inside the container, so the proxy device's
`connect=tcp:127.0.0.1:8080` reaches the service. The container has its
own veth on `incusbr0`; nothing on the host's interfaces is involved
until traffic hits the proxy device on `<listen-ip>:<host-port>`.

## Operator flow

### First deploy of an app

```sh
incus-pet deploy github:srid/anywhen --port 7700 --listen 100.122.32.106
```

This:

1. Synthesises a marshaling flake under `~/.local/state/incus-pet/anywhen/`
   exposing `nixosModules.default` (essentials + app's
   `nixosModules.incus` + operator pubkey overlay) — no nixpkgs pin in
   per-deploy state.
2. Launches `images:nixos/25.11` as container `anywhen` with
   `-c security.nesting=true`.
3. Pushes your `~/.ssh/id_ed25519.pub` into the container's
   `/root/.ssh/authorized_keys` (the image already runs sshd via systemd
   socket activation).
4. Builds the system toplevel against `github:nixos/nixpkgs/nixos-25.11`
   (stable, matching the image baseline) via `nix build --impure --expr`.
5. Copies the closure with `nix copy --to ssh://root@<container-ip>
   --substitute-on-destination`.
6. SSHes to set the system profile and run `switch-to-configuration switch`.
7. Records `--port` and `--listen` in container metadata.
8. Adds the `web` proxy device.

### Subsequent deploys

```sh
incus-pet deploy github:srid/anywhen   # picks up new commits on the branch
```

No flags needed — `--port` and `--listen` are read from metadata.

### Listing what's running

```sh
incus-pet list
```

Filters `incus list` to only containers tagged with
`user.incus-pet.flake-ref`.

### Removing

```sh
incus-pet rm anywhen
```

Stops and deletes the container, removes the marshaling flake from
`~/.local/state/incus-pet/anywhen/`. Container metadata goes with the
container.

## Failure modes

- **`incus not in PATH`** — the host needs the incus daemon installed
  and the operator's user in `incus-admin` (log out and back in after
  the group is added).
- **`first deploy of <name> needs --port N`** — pass `--port`; it will
  be recorded in container metadata for next time.
- **`container did not get an IPv4 address within 30s`** — usually
  means `incusbr0` didn't come up. Check `incus network list` and
  `systemctl status incus-preseed`.
- **`Failed to start Firewall.` inside the container** — the launch
  flag `-c security.nesting=true` is supposed to handle this; if it
  recurs, see `../README.md` and lxc/incus#526.
- **`switch-to-configuration` exits 4** — "some units failed to
  reload/restart". Treated as success: the activation itself
  completed, only a unit reload (typically dbus-broker) failed. The
  service is up.
- **`switch-to-configuration` exits 11 / "Could not acquire lock"** —
  a previous activation is still running (often hung). `incus exec
  <name> -- pkill -9 -f switch-to-configuration` clears it.

## State

| What                          | Where                                                                 |
|-------------------------------|-----------------------------------------------------------------------|
| Marshaling flake + lock       | `~/.local/state/incus-pet/<name>/{flake.nix, flake.lock}`             |
| Operator-chosen host port     | `incus config get <name> user.incus-pet.host-port`                    |
| Operator-chosen listen IP     | `incus config get <name> user.incus-pet.listen`                       |
| Source flake ref              | `incus config get <name> user.incus-pet.flake-ref`                    |
| Service data                  | Inside the container, per the app's `services.<app>.stateDir`         |

The marshaling flake carries no app-specific values — only the
assembly. App config lives entirely in the upstream flake's
`nixosModules.incus`.
