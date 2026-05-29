# Nix Eval-Time Optimization (Ralph)

Iterative measurement-driven reduction of Nix **evaluation** time for the two
configs that get evaluated most often on this machine:

- `pureintent` — the NixOS system (`nixosConfigurations.pureintent`)
- `zest` — the home-manager config (`homeConfigurations."srid@zest"`)

## Methodology

Primary metric: **`cpuTime`** from `NIX_SHOW_STATS=1` — it isolates pure
evaluation work and is stable run-to-run (~3% spread). Wall-clock is reported
too but is IO/cache-bound and noisy (±15%), so it is *not* used for commit
decisions.

```sh
# docs/eval-bench.sh <runs>   (default 5)
# - persistent $HOME=/tmp/ralph-evalhome keeps the fetcher/git cache warm
# - --option eval-cache false forces a full re-eval every run
# - reports median cpuTime + median wall over N runs, per target
nix eval --raw .#nixosConfigurations.pureintent.config.system.build.toplevel.drvPath --option eval-cache false
nix eval --raw '.#homeConfigurations."srid@zest".activationPackage.drvPath'        --option eval-cache false
```

No `nix store gc` between runs (per request). The eval cache is disabled rather
than cleared, so the warm fetcher cache removes input-fetch noise.

**Commit rule:** commit only if median cpuTime improves >3% for a target with no
regression on the other. Behaviour may change *only* by dropping inputs/features
first confirmed unused.

## Baseline (median of 5)

| Target     | cpuTime (s) | wall (s) | cpuTime runs |
|------------|-------------|----------|--------------|
| pureintent | **23.17**   | 38.91    | 21.99 / 23.45 / 23.76 / 23.17 / 22.74 |
| zest       | **14.93**   | 22.09    | 14.93 / 14.50 / 13.86 / 15.49 / 14.96 |

Env: nix 2.34.7, x86_64-linux. Stats at baseline (pureintent): nrThunks 20.4M,
nrFunctionCalls 13.0M, sets.bytes 868MB, values.bytes 503MB, gcFraction 0.058.

## Optimization log

| Cycle | Change | pureintent | zest | Verdict |
|-------|--------|------------|------|---------|
| 0 | baseline | 23.17 | 14.93 | — |

## Dead ends

_(investigated, no improvement — recorded so we don't retry)_

## Key findings

_(filled in at wrap-up)_
