# Nix Eval-Time Optimization (Ralph)

Iterative measurement-driven reduction of Nix **evaluation** time for the two
configs that get evaluated most often on this machine:

- `pureintent` — the NixOS system (`nixosConfigurations.pureintent`)
- `zest` — the home-manager config (`homeConfigurations."srid@zest"`)

## Methodology

Primary metric: **deterministic eval-work counters** from `NIX_SHOW_STATS=1` —
`nrThunks`, `nrFunctionCalls`, `nrPrimOpCalls`. These count the actual evaluation
work and are **byte-identical across runs** (independent of CPU clock, load, GC).

> **Why not `cpuTime`/wall?** Initially planned, but rejected after measuring:
> this is a live, thermally-throttling laptop. The *same* eval (identical
> nrThunks every run) reported cpuTime climbing 11s → 21s monotonically as the
> CPU clock dropped under sustained load. Time is meaningless here; counters are
> exact. A 1% drop in nrThunks is a real 1% less work the evaluator must do, on
> any machine. Single eval per target — no median needed.

```sh
# docs/eval-bench.sh [target]      target = pureintent | zest | (both)
# - persistent $HOME=/tmp/ralph-evalhome keeps the fetcher/git cache warm
# - --option eval-cache false forces a full re-eval every run
# - reports nrThunks / nrFunctionCalls / nrPrimOpCalls per target (deterministic)
nix eval --raw .#nixosConfigurations.pureintent.config.system.build.toplevel.drvPath --option eval-cache false
nix eval --raw '.#homeConfigurations."srid@zest".activationPackage.drvPath'        --option eval-cache false
```

No `nix store gc` between runs (per request). The eval cache is disabled rather
than cleared, so the warm fetcher cache removes input-fetch noise.

**Commit rule:** commit only if `nrThunks` improves >3% for a target with no
regression on the other. (Counters have ~zero noise, so any real reduction
counts; >3% is the bar for a "meaningful" cycle.) Behaviour may change *only* by
dropping inputs/features first confirmed unused.

Profiling tool: `nix eval … --eval-profiler flamegraph --eval-profile-file f`
then aggregate self/inclusive frames (collapsed-stack format).

## Baseline (nrThunks / nrFunctionCalls / nrPrimOpCalls)

| Target     | nrThunks   | nrFunctionCalls | nrPrimOpCalls |
|------------|------------|-----------------|---------------|
| pureintent | 20,400,114 | 12,975,268      | 6,507,025     |
| zest       | 11,066,680 |  7,091,428      | 3,587,586     |

Env: nix 2.34.7, x86_64-linux.

## Optimization log

(Δ% is on nrThunks vs baseline for the affected target.)

| Cycle | Change | pureintent thunks | zest thunks | Verdict |
|-------|--------|-------------------|-------------|---------|
| 0 | baseline | 20,400,114 | 11,066,680 | — |
| 1 | pureintent: `documentation.nixos.enable = false` (drop NixOS options manual; option doc-strings no longer evaluated) | **19,201,996 (−5.9%)** | 11,066,680 | ✅ commit |

## Dead ends

_(investigated, no improvement — recorded so we don't retry)_

## Key findings

_(filled in at wrap-up)_
