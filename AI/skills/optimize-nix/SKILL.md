---
name: optimize-nix
description: Optimize Nix flake evaluation and `nix develop` startup time. Use when the user wants to speed up nix develop, nix-shell, or flake evaluation.
---

# Nix Flake Evaluation Optimization

Systematic approach to reducing `nix develop` startup time.

## Workflow

Iterative optimization loop. For each change:

1. **Measure** baseline (5 samples, isolated `$HOME` to avoid cache interference)
2. **Change** one thing
3. **Measure** again
4. **Commit** with before/after measurements in the commit message
5. **Push** to the PR branch
6. **CI** after each significant change
7. Repeat

### Setup

Create a branch and open a **draft PR** before starting. Each optimization gets its own commit.

### Measurement

Use isolated `$HOME` so measurements don't destroy the developer's caches:

```bash
for i in 1 2 3 4 5; do
  rm -rf /tmp/nix-bench/home && mkdir -p /tmp/nix-bench/home
  { time HOME=/tmp/nix-bench/home nix develop -c echo "s$i" 2>/dev/null; } 2>&1 | grep real
done
```

Also measure warm (daemon-cached) performance — just run without resetting `$HOME`:

```bash
# warm up first
HOME=/tmp/nix-bench/home nix develop -c echo warmup 2>/dev/null
for i in 1 2 3; do
  { time HOME=/tmp/nix-bench/home nix develop -c echo "s$i" 2>/dev/null; } 2>&1 | grep real
done
```

### Commit Format

Use conventional commits. Include measurements in every commit body.

## Where Time Goes

`nix develop` time breaks down into:

1. **Flake fetcher-cache verification** (~1.5s per input) — nix re-verifies each input on every cold invocation. This is the #1 bottleneck.
2. **Nixpkgs evaluation** (~0.2-0.5s) — importing the nixpkgs tree.
3. **Package resolution** (~0.5-1.5s) — resolving specific packages.
4. **Shell env realization** (~0.3-0.7s) — daemon overhead for building the shell derivation.

### Key Insight

With **zero flake inputs**, `nix develop` is fast: ~2.6s cold, ~0.3s warm (daemon eval cache). Each flake input adds ~1.5s. A typical flake with 4+ inputs (nixpkgs, flake-parts, git-hooks, systems) costs 7-18s.

## The Fix: Zero-Input Flake

**Import nixpkgs via `fetchTarball` instead of as a flake input.** This eliminates all fetcher-cache overhead while keeping `nix develop` as the interface.

### Architecture

```
nix/nixpkgs.nix   ← single nixpkgs pin (fetchTarball)
default.nix        ← all packages + shared koluEnv
shell.nix          ← devShell (imports default.nix, accepts { pkgs } arg)
flake.nix          ← zero inputs, imports the above, exports packages + devShells
```

### Source management with npins

Use [npins](https://github.com/andir/npins) to manage all fetched sources (nixpkgs, GitHub repos, etc.). This replaces hardcoded `fetchTarball`/`fetchFromGitHub` calls with a single `npins/sources.json`.

```bash
npins init --bare
npins add github nixos nixpkgs --branch nixpkgs-unstable --at <REV>
npins add github owner repo --branch main --at <REV>
npins update          # bump all sources
npins update nixpkgs  # bump just nixpkgs
```

### `nix/nixpkgs.nix` — Single source of truth

```nix
# Managed by npins. To update: npins update nixpkgs
let sources = import ../npins;
in import sources.nixpkgs
```

Other nix files can also use `sources`:

```nix
# nix/some-dep/default.nix
{ pkgs }:
let sources = import ../../npins;
in pkgs.runCommand "foo" {} ''
  cp -r ${sources.some-repo}/bar $out
''
```

Note: npins handles GitHub repos and tarballs. Plain `fetchurl` (e.g. font files from CDNs) stays hardcoded.

### `flake.nix` — Zero inputs

```nix
# IMPORTANT: This flake intentionally has ZERO inputs.
#
# nixpkgs is imported via fetchTarball in nix/nixpkgs.nix, bypassing the
# flake input system. Each flake input adds ~1.5s of fetcher-cache
# verification. With zero inputs, `nix develop` cold is ~2.6s, warm ~0.3s.
#
# DO NOT add flake inputs (nixpkgs, flake-parts, git-hooks, etc.).
# Instead, use fetchTarball or callPackage in nix/ files.
{
  outputs = { self, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      eachSystem = f: builtins.listToAttrs (map
        (system: {
          name = system;
          value = f (import ./nix/nixpkgs.nix { inherit system; });
        })
        systems);
      commitHash = self.shortRev or self.dirtyShortRev or "dev";
    in
    {
      packages = eachSystem (pkgs:
        let all = import ./default.nix { inherit pkgs commitHash; };
        in removeAttrs all [ "koluEnv" ]);  # koluEnv is not a derivation
      devShells = eachSystem (pkgs:
        { default = import ./shell.nix { inherit pkgs; }; });
    };
}
```

### `shell.nix` — Shared devShell

```nix
{ pkgs ? import ./nix/nixpkgs.nix { } }:
let packages = import ./default.nix { inherit pkgs; };
in pkgs.mkShell {
  name = "my-shell";
  # Use mkShell's env attr — no duplicate export lines
  env = packages.koluEnv // { ... };
  shellHook = ''...'';
  packages = with pkgs; [ ... ];
}
```

### DRY shared env vars

Define env vars once in `default.nix` as an attrset, use in both the build derivation's `env` and `mkShell`'s `env`:

```nix
# In default.nix
koluEnv = {
  KOLU_THEMES_JSON = "${ghosttyThemes}/themes.json";
  KOLU_FONTS_DIR = "${fonts}";
};

kolu = pkgs.stdenv.mkDerivation {
  env = { npm_config_nodedir = nodejs; } // koluEnv;
  ...
};
```

**Important:** `koluEnv` is not a derivation — filter it out of flake `packages` output with `removeAttrs` or devour-flake will fail trying to build it.

### Replacements for common flake inputs

- **flake-parts** → `eachSystem` helper (3 lines)
- **systems** → inline `[ "x86_64-linux" "aarch64-darwin" ]`
- **git-hooks.nix** → static `.pre-commit-config.yaml` + tools in devShell
- **process-compose-flake** → just's `[parallel]` attribute

### `.envrc`

```
use flake
```

### justfile

```just
nix_shell := if env('IN_NIX_SHELL', '') != '' { '' } else { 'nix develop path:' + justfile_directory() + ' -c' }
```

## Why Not nix-shell or env caching?

We benchmarked all approaches with a zero-input flake:

| Approach | Cold | Warm |
|---|---|---|
| `nix develop` (zero inputs) | **2.6s** | **0.3s** |
| `nix-shell` (fetchTarball) | 2.4s | 2.4s (no daemon cache) |
| env caching script | 5s miss | 0.014s hit |

`nix develop` wins: 0.3s warm with zero maintenance. `nix-shell` has no daemon eval cache so it's always 2.4s. Env caching (nix-shell-fast) achieves 0.014s but introduces staleness bugs, manual cache key maintenance, and shellHook side-effects not re-running — complexity not worth the gain.

## Pitfalls

- **`nix flake lock` silently bumps inputs** — when removing inputs, nix may update remaining ones to latest. Always verify the nixpkgs rev matches master's. Run CI after any lock change.
- **`fetchTarball` sha256** — use SRI format (`sha256-...`). With npins, hashes are managed automatically.
- **npins `default.nix` is auto-generated** — don't edit it manually; `npins` overwrites it. Mark it in `.gitattributes` as `linguist-generated`.
- **Non-derivation in packages** — if `default.nix` exports non-derivations (like a `koluEnv` attrset), filter them out in `flake.nix` or devour-flake/`nix flake check` will fail.
- **direnv cache staleness** — after changing `nix/nixpkgs.nix`, delete `.direnv/` to force direnv re-evaluation. Otherwise `use flake` serves stale env vars.

## Expected Results

| | Cold eval cache | Warm (daemon cached) |
|---|---|---|
| Before (4+ inputs) | 7-18s | 3-7s |
| After (0 inputs) | ~2.6s | ~0.3s |
