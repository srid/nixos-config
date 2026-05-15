# Ralph: pureintent eval-time optimization

Iterative measurement-driven shrinking of `nixosConfigurations.pureintent`
evaluation time, following the [Ralph
skill](https://github.com/srid/agency/blob/master/.apm/skills/ralph/SKILL.md).

## Methodology

- **Host**: `srid-nc` (NixOS, x86_64-linux, Nix 2.31.5)
- **Repo**: cloned at `~/ralph/nixos-config`, branch `optimize-eval`
- **Command**:
  ```
  /usr/bin/env time -f "%e" \
    nixos-rebuild dry-build --flake .#pureintent \
                  --option eval-cache false
  ```
  - `dry-build` so no derivations are actually realised.
  - `--option eval-cache false` because every meaningful source change
    invalidates the flake eval-cache — measuring with a hot eval-cache
    just measures sqlite lookups (~0.5 s) and tells us nothing about the
    work this PR is meant to cut.
  - Filesystem / Nix-store cache is warm (we ran the build once to
    populate everything).
- **Baseline policy**: 5–7 consecutive runs, report **median**, range,
  and `NIX_SHOW_STATS` counters (`nrFunctionCalls`, `nrThunks`,
  `totalBytes`, etc.).
- **Noise floor**: ≈0.5 % (range was 0.06 s on a 10.87 s run). Commit
  threshold per Ralph rules: **> 3 %**.
- **Constraints**: (1) other NixOS / home configs must still build,
  (2) pureintent runtime behaviour preserved (drv hash may shift),
  (3) reducing flake inputs is in scope (npins-style relocation OK).

## Baseline

7 warm runs, eval-cache disabled, `nixos-rebuild dry-build .#pureintent`:

| run | seconds |
|----:|--------:|
| 1   | 10.87 |
| 2   | 10.87 |
| 3   | 10.86 |
| 4   | 10.88 |
| 5   | 10.86 |
| 6   | 10.85 |
| 7   | 10.91 |

**Median: 10.87 s** &middot; range 0.06 s (≈ 0.5 %).

`NIX_SHOW_STATS` for one baseline eval:

| counter | value |
|---|---:|
| CPU time | 16.29 s |
| GC fraction | 3.3 % |
| `nrFunctionCalls` | 25 043 557 |
| `nrPrimOpCalls` | 12 110 404 |
| `nrThunks` | 38 038 010 |
| `nrAvoided` | 32 199 960 |
| `nrLookups` | 16 259 247 |
| `nrOpUpdates` | 2 469 935 |
| `nrOpUpdateValuesCopied` | 85 701 830 |
| `values.number` | 57 025 753 |
| `values.bytes` | 912 412 048 |
| `sets.elements` | 120 709 352 |
| `sets.bytes` | 2 059 750 432 |
| `totalBytes` | 4 139 856 480 |
| `maxRss` | 3 120 MB |

## Flake input inventory

Inputs declared in `flake.nix`:

`agenix`, `disc-scrape`, `disko`, `emanote`, `flake-parts`, `git-hooks`,
`github-nix-ci`, `home-manager`, `imako`, `jumphost-nix`, `kolu`,
`landrun-nix`, `llm-agents`, `nix-darwin`, `nix-index-database`,
`nixos-hardware`, `nixos-unified`, `nixos-vscode-server`, `nixpkgs`,
`nixvim`, `project-unknown`, `vira`, `zmx`.

Per-input blame is filled in as cycles run.

## Optimization log

| # | hypothesis | mutation | wall (s) | Δ vs baseline | committed? | notes |
|---|---|---|---|---|---|---|
| 0 | — | baseline | 10.87 | — | — | reference |

## Dead ends

(none yet)

## Key findings

(filled in at wrap-up)
