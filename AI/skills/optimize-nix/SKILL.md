---
name: optimize-nix
description: Optimize Nix flake evaluation and `nix develop` startup time. Use when the user wants to speed up nix develop, nix-shell, or flake evaluation.
---

# Nix Flake Evaluation Optimization

Systematic approach to reducing `nix develop` / `nix-shell` startup time.

## Workflow

This is an iterative optimization loop. For each optimization:

1. **Measure** baseline (3 samples, cold eval cache)
2. **Change** one thing
3. **Measure** again
4. **Commit** with measurements in the commit message
5. **Push** to the PR branch
6. Repeat

### Setup

Create a branch and open a **draft PR** before starting. Each optimization gets its own commit with before/after measurements in the message body.

```bash
git checkout -b optimize/nix-develop-time
git push -u origin optimize/nix-develop-time
# Create draft PR (use github-pr skill for title/body)
```

### Commit Format

Use conventional commits. Include measurements in every commit:

```
perf: switch devShell from nix develop to nix-shell

`nix develop` pays ~7s in flake fetcher-cache verification.
`nix-shell` with fetchTarball skips this entirely.

Measurement (3 samples, cold eval cache / warm store):
  Before: 7.35s, 7.22s, 7.20s  (avg ~7.3s)
  After:  2.34s, 2.34s, 2.36s  (avg ~2.35s)
```

### CI

Run CI after each significant change to catch regressions (especially `nix flake lock` silently bumping nixpkgs — see Pitfalls).

## Measurement Protocol

Always measure before and after each change. The metric is wall-clock time with cold eval cache:

```bash
# Cold eval cache, warm nix store (typical dev scenario)
rm -rf ~/.cache/nix; time nix develop -c echo "test"

# Take 3 samples for stability
for i in 1 2 3; do rm -rf ~/.cache/nix; { time nix develop -c echo "s$i" 2>/dev/null; } 2>&1 | grep real; done
```

Profile with `NIX_SHOW_STATS=1 nix eval ...` to get eval stats (function calls, thunks, set operations).

## Where Time Goes

`nix develop` time breaks down into:

1. **Flake fetcher-cache verification** (~1.5s per input) — nix verifies each flake input against its fetcher cache even when nothing changed. This is the #1 bottleneck.
2. **Nixpkgs evaluation** (~0.2-0.5s) — importing and evaluating the nixpkgs tree.
3. **Package resolution** (~0.5-1.5s) — resolving specific packages (playwright-driver is notably expensive at ~0.4s).
4. **Shell environment realization** (~0.5-0.7s) — nix-shell/nix-develop daemon overhead for building the shell env derivation.
5. **Flake-parts / module system** — adds eval overhead but is NOT the main bottleneck despite appearances.

### Key Insight

The **fetcher-cache verification** dominates. Even a flake with a single `nixpkgs` input costs ~7s on cold eval cache. Each additional input adds ~1.5s. This cost is inherent to `nix develop` and cannot be optimized away within the flake framework.

## Optimization Tiers

### Tier 1: Reduce Flake Inputs (moderate gain)

Remove unnecessary flake inputs. Each removed input saves ~1.5s on cold eval cache.

Common removable inputs:
- **flake-parts** → replace with a simple `eachSystem` helper (3 lines of nix)
- **systems** → inline the systems list
- **git-hooks.nix** → use a static `.pre-commit-config.yaml` with tools from the devShell
- **process-compose-flake** → use just's `[parallel]` attribute or shell-based concurrency

```nix
# Replace flake-parts with:
eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
```

### Tier 2: Switch from `nix develop` to `nix-shell` (large gain)

`nix-shell` with `fetchTarball` bypasses flake fetcher-cache entirely. Typical improvement: **7s → 2.5s**.

Create a `shell.nix` alongside the flake:

```nix
# nix/nixpkgs.nix — single source of truth for the nixpkgs pin
import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/<REV>.tar.gz";
  sha256 = "<NARHASH>";
})
```

```nix
# shell.nix
let pkgs = import ./nix/nixpkgs.nix { };
in pkgs.mkShell { ... }
```

Keep `flake.nix` as a thin compat wrapper for CI and downstream consumers:

```nix
# flake.nix — zero inputs, imports nix/nixpkgs.nix directly
{
  outputs = { self, ... }:
    let
      eachSystem = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f (import ./nix/nixpkgs.nix { inherit system; });
      }) [ "x86_64-linux" "aarch64-darwin" ]);
    in {
      packages = eachSystem (pkgs: import ./default.nix { inherit pkgs; });
    };
}
```

Update `.envrc` from `use flake` to `use nix`.

Update justfile's nix_shell prefix to use a wrapper script instead of `nix develop -c`.

### Tier 3: Environment Caching (massive gain)

Cache the full shell environment (`export -p`) keyed on content hashes of nix input files. Typical improvement: **2.5s → 0.015s**.

Create a `nix-shell-fast` wrapper script:

```bash
#!/usr/bin/env bash
# nix-shell-fast — cached nix-shell replacement (~0.015s vs ~2.5s)
#
# Runs a command inside the shell.nix environment, caching the full set of
# exported env vars on first use. Subsequent calls eval the cache and exec
# directly, skipping nix entirely.
#
# Cache invalidation:
#   Content hash of listed nix files. Any byte change → cache miss → re-eval.
#   IMPORTANT: add new .nix files to CACHE_KEY when shell.nix/default.nix imports them.
#
# Known limitations:
#   - shellHook side-effects (pre-commit install, symlinks) only run on cache miss.
#   - Only one store path checked for GC validity. rm cache dir to force re-eval.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/<project>-shell"

CACHE_KEY=$(cat "$DIR/shell.nix" "$DIR/default.nix" "$DIR/nix/nixpkgs.nix" \
    <other nix files> 2>/dev/null | sha256sum | cut -d' ' -f1)
ENV_FILE="$CACHE_DIR/$CACHE_KEY.env"

cache_valid() {
  [[ -f "$ENV_FILE" ]] || return 1
  local store_path
  store_path=$(grep '^declare -x PATH=' "$ENV_FILE" | grep -o '/nix/store/[^/:]*' | head -1)
  [[ -n "$store_path" ]] && [[ -e "$store_path" ]]
}

if ! cache_valid; then
  mkdir -p "$CACHE_DIR"
  find "$CACHE_DIR" -maxdepth 1 -type f -not -name "$CACHE_KEY.*" -delete 2>/dev/null || true
  nix-shell "$DIR/shell.nix" --run 'export -p' 2>/dev/null | grep '^declare -x ' > "$ENV_FILE.tmp"
  mv "$ENV_FILE.tmp" "$ENV_FILE"
fi

eval "$(cat "$ENV_FILE")"
exec "$@"
```

Then in justfile:

```just
nix_shell := if env('IN_NIX_SHELL', '') != '' { '' } else { justfile_directory() + '/nix-shell-fast' }
```

## Pitfalls

- **`nix flake lock` silently bumps inputs** — when you remove inputs and run `nix flake lock`, nix may update remaining inputs to latest. Always verify the nixpkgs rev matches what was in the original flake.lock. Pin explicitly. Run CI after any flake.lock change.
- **`fetchTarball` sha256 format** — use the `narHash` from flake.lock (SRI format `sha256-...`), not the base32 nix hash.
- **Cache key completeness** — include ALL files that affect the shell evaluation: shell.nix, default.nix, nix/nixpkgs.nix, and any files imported by callPackage (fonts, themes, etc.). When adding a new .nix file that shell.nix imports, add it to the CACHE_KEY line.
- **macOS compatibility** — `sha256sum` exists on NixOS but may not on stock macOS. If targeting macOS without nix in PATH, use `shasum -a 256` as fallback.
- **nix-shell `export -p` output** — contains shellHook stdout (e.g., "Sourcing pytest-check-hook"). Filter with `grep '^declare -x '`.
- **Store path validation** — after `nix-collect-garbage`, cached env vars may point to deleted store paths. Validate at least one store path from PATH before using the cache.
- **shellHook side-effects** — the env cache stores the *result* of shellHook (env vars), not the commands. Things like `pre-commit install` or `ln -sfn` only run on cache miss. To force: `rm -rf ~/.cache/<project>-shell`.

## Expected Results

| Tier | Typical Time | Improvement |
|------|-------------|-------------|
| Baseline (nix develop, multiple inputs) | 7-18s | — |
| Tier 1 (fewer inputs) | 5-7s | ~1.5x |
| Tier 2 (nix-shell) | 2-3s | ~3x |
| Tier 3 (env cache) | 0.01-0.02s | ~500x |

Cache miss (first run after nix file changes) still costs Tier 2 time (~2.5s).
