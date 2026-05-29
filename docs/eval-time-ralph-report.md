# Nix Eval-Time Optimization (Ralph)

Iterative measurement-driven reduction of Nix **evaluation** time for the two
configs that get evaluated most often on this machine:

- `pureintent` — the NixOS system (`nixosConfigurations.pureintent`)
- `sincereintent` — the home-manager config (`homeConfigurations."srid@sincereintent"`)

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
nix eval --raw '.#homeConfigurations."srid@sincereintent".activationPackage.drvPath' --option eval-cache false
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
| pureintent    | 20,400,114 | 12,975,268      | 6,507,025     |
| sincereintent |  5,323,428 |  3,227,404      | 1,565,120     |

Env: nix 2.34.7, x86_64-linux.

## Optimization log

(Δ% is on nrThunks vs baseline for the affected target.)

| Cycle | Change | pureintent thunks | sincereintent thunks | Verdict |
|-------|--------|-------------------|----------------------|---------|
| 0 | baseline | 20,400,114 | 5,323,428 | — |
| 1 | pureintent: `documentation.nixos.enable = false` (drop NixOS options manual; option doc-strings no longer evaluated) | **19,201,996 (−5.9%)** | 5,323,428 | ✅ commit |
| 2 | home: `manual.manpages.enable = false` in shared `modules/home/default.nix` (drop home-manager options manpage; evaluated every HM option's doc) | **17,431,437 (−9.2%)** | **3,551,679 (−33.3%)** | ✅ commit |

> Note: `modules/home/default.nix` is also fed to every Linux system's *embedded*
> home-manager via `modules/nixos/default.nix`, so cycle 2 reduced pureintent
> too (its HM user's manpages were previously on).

| 3 | (profiling cycle — no change) investigated nixpkgs double-instantiation, unused inputs, `escapeShellArg` hotspot | 17,431,437 | 3,551,679 | — no behaviour-preserving win found |
| 4 | home: drop heavy `home.packages` from shared `cli/terminal.nix` — `yt-dlp`, `lima`, `omnix`, `pandoc`, `google-cloud-sdk` (kept `hledger`). *Behaviour change, user-approved.* | **16,989,720 (−2.5%)** | **2,757,201 (−22.4%)** | ✅ commit |

## Dead ends

_(investigated, no improvement — recorded so we don't retry)_

- **nixpkgs is NOT double-instantiated.** `nixos-unified.lib.mkLinuxSystem` calls
  `nixpkgs.lib.nixosSystem` without pinning `nixpkgs.pkgs`, but the NixOS
  `nixpkgs` module imports the package set exactly once; the `pkgs/top-level/impure.nix`
  frame in the profile is that single import. `home-manager.useGlobalPkgs = true`
  (set by nixos-unified) already shares it with the embedded HM. No win available.
- **Dropping unused flake inputs does not reduce eval counters.** Nix input
  evaluation is lazy: an input not referenced during a config's eval (e.g.
  `nixos-hardware`, `git-hooks` — 0 refs) contributes ~0 thunks to that config.
  Pruning them shrinks `flake.lock`/`nix flake` overhead only, not `nrThunks`.
- **`escapeShellArg` (~72% inclusive on pureintent) is not a fixable hotspot.**
  It is driven by `home-manager` file-linking (`files.nix:442`, ~43% — one
  escaped command per managed dotfile) and NixOS `/etc` generation
  (`etc.nix:58`). Both scale with how much is managed; nixpkgs/HM own the
  implementation. Not patchable from this repo.
- **`programs.command-not-found` already disabled** by the `nix-index-database`
  module; nothing to gain.

## Remaining cost is feature-bound

After the two documentation wins, the dominant `derivationStrict` targets in the
pureintent eval profile are all *wanted* features (samples ≈ inclusive share):
`home-manager-generation`/`home-manager-files` (~43%, embedded HM), `/etc`
(~29%), `vira.service`+`vira-wrapped`+`vira-0.1.0.0` (Haskell app), `kolu.service`,
`pipewire`, plus heavy packages in `home.packages` (`google-cloud-sdk`, `pandoc`,
`omnix` — Haskell). Further reductions require trading a feature, not a free
structural change.

## Key findings

_(filled in at wrap-up)_
