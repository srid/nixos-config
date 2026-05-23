---
name: incus-pet
description: Deploy a NixOS service flake into a per-app incus container
  ("pet PaaS") on the local host — OR add the required nixosModules.incus
  contract to a flake so it becomes deployable. Use when the user says
  "deploy X", "make this app deployable", "add incus to this flake", or
  "publish this on my box".
argument-hint: "deploy <flake-ref> [<name>] [--port N] [--listen IP]"
---

# incus-pet

A per-app incus container deploys a flake-shipped NixOS service onto the
local host, exposed on a chosen `<listen-ip>:<host-port>` that proxies to
a fixed `8080` inside the container.

Pick the branch from context:

- User in their OWN app's repo, "make this deployable"          → **Branch C**
- User wants to add the contract to an UPSTREAM they can PR to
  (e.g. juspay/kolu) — agent has push/PR access                 → **Branch C**
- Flake-ref already ships `nixosModules.incus`                  → **Branch A**
- Upstream won't accept a PR and user explicitly wants a local
  wrapper                                                       → **Branch B**

## Branch A — deploy a flake that ships the contract

Run:

```
incus-pet deploy <flake-ref> [<name>] [--port N] [--listen IP]
```

`--port` is required on the first deploy of a given `<name>` and recorded
in container metadata; subsequent deploys read it back. Report the
`<listen>:<port>` URL to the user.

## Branch B — local stand-alone wrapper (RARE; Branch C is preferred)

Only when upstream won't accept the contract. Create a tiny wrapper flake
locally:

- `flake.nix` exposing `nixosModules.incus` per the contract
- `service-module.nix` authoring `services.<app>` as a NixOS system
  module (mirror the upstream's home-manager module if any)
- Add the upstream as a flake input

Then `incus-pet deploy ./path/to/wrapper <app>`.

## Branch C — add the contract to a flake (yours or upstream-via-PR)

Steps:

1. Verify the flake exposes `packages.<system>.default`. If not, stop —
   prerequisite is a package derivation with `meta.mainProgram`.

2. Verify `nixosModules.default` (the service module). If MISSING but the
   flake has `homeManagerModules.default` (kolu case):
   - Author `nix/nixos/module.nix` as a system NixOS module mirroring the
     home-manager surface — same options (`enable`, `package`, `host`,
     `port`, ...), emitting `systemd.services.<app>` instead of a
     home-manager unit.
   - Expose as `nixosModules.default` in flake outputs.

   If MISSING entirely (no module at all), stop — prerequisite.

3. Add `nixosModules.incus` to outputs (fill in `<app>`):

   ```nix
   nixosModules.incus = { config, lib, pkgs, ... }: {
     imports = [ self.nixosModules.default ];
     incus.container = {
       enable   = true;
       hostname = lib.mkDefault "<app>";
     };
     system.stateVersion = "25.05";
     services.<app> = {
       enable  = true;
       package = lib.mkDefault
         self.packages.${pkgs.stdenv.hostPlatform.system}.default;
       host    = lib.mkDefault "0.0.0.0";
       port    = 8080;  # fixed by the incus-pet contract
     };
   };
   ```

4. If `services.<app>` doesn't expose `{host, port, package}` (or
   equivalents), surface as prerequisite. Do not invent options that
   aren't there — add them to the service module first.

5. Smoke-test:

   ```
   nix flake check
   nix eval .#nixosModules.incus
   ```

6. If upstream (PR mode), open the PR. Else commit.

7. Tell the user how to deploy:

   ```
   incus-pet deploy github:<owner>/<repo> --port <chosen> --listen <ip>
   ```

Do NOT add `example/`-style sub-flakes or VM tests in this branch —
separate scope.

## Contract for `nixosModules.incus`

The module must set:

- `incus.container.enable    = true`
- `incus.container.hostname  = "<app>"`           (`mkDefault` ok)
- `system.stateVersion       = "25.05"`
- `services.<app>.{enable, package, host, port}`  (`port = 8080`,
  hardcoded — this is the incus-pet convention)

The module must NOT set:

- `services.<app>.port` to anything other than `8080`
- `networking.firewall.allowedTCPPorts` — `container.nix` opens 8080

## Idempotence + failure modes

- Re-running `incus-pet deploy <flake-ref>` against an existing container
  is safe: marshaling flake is rewritten and re-locked; container
  bootstrap is idempotent; proxy device is `set` if present, else `add`.
- Container metadata (`user.incus-pet.{host-port,listen,flake-ref}`) is
  the source of truth for the operator-chosen exposure. `incus-pet list`
  filters by the `flake-ref` key.
- If `--port` is missing on the first deploy, the command fails before
  launching anything.
- Network failures during `nixos-rebuild --target-host` leave the
  container running its previous generation — `nixos-rebuild switch` is
  itself atomic.
