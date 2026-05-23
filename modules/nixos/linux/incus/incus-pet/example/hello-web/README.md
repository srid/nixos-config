# hello-web — incus-pet reference example

Smallest possible flake that satisfies the [incus-pet contract](../../SKILL.md).
A static HTTP server (`darkhttpd` wrapping a one-page `index.html`) packaged
through the full stack:

- `packages.<sys>.default` — the binary
- `nixosModules.default` — `services.hello-web.{enable, package, host, port}` + a systemd unit
- `nixosModules.incus` — the deploy contract (binds 8080 inside a `hello-web` container)

## Build it standalone

```sh
nix build path:./modules/nixos/linux/incus/incus-pet/example/hello-web

# Then run it locally — listens on 0.0.0.0:8080.
./result/bin/hello-web &
curl http://127.0.0.1:8080
```

## Deploy it as an incus-pet container

From a host that has the incus daemon and the `incus-pet` CLI on PATH:

```sh
nix run path:.#incus-pet -- deploy \
  path:./modules/nixos/linux/incus/incus-pet/example/hello-web \
  hello-web --port 8081 --listen 100.122.32.106

curl http://100.122.32.106:8081
```

`incus-pet list` will show the running container; `incus-pet rm hello-web`
tears it down.

## What to read next

The flake here is meant to be a working template. Compare the three
outputs (`packages.default`, `nixosModules.default`, `nixosModules.incus`)
side-by-side with what srid/anywhen ships — same shape, scaled down.
