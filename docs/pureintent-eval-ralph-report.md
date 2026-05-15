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

Per-input blame from Phase-1 probes (drop the module that imports the
input; everything else held constant; 3 runs each, eval-cache off):

| input / module | path | wall when dropped | Δ saved | share |
|---|---|---:|---:|---:|
| baseline | — | 10.87 | — | 100 % |
| `nixvim` | `modules/home/editors/neovim/` | 6.90 | **3.97** | **36.5 %** |
| `vira` | `modules/home/services/vira.nix` | 9.59 | 1.28 | 11.8 % |
| `jumphost-nix` | `modules/home/work/juspay.nix` | 8.16 (vira out, jumphost-nix import removed) | 1.43 | 13.1 % |
| `kolu` | `modules/home/services/kolu.nix` | 10.37 | 0.50 | 4.6 % |
| `agenix` (HM module) | `modules/home/agenix.nix` | ≈ 8.07 | ≈ 0 | < noise |
| `agenix` (NixOS module) | `modules/nixos/common.nix:agenix` | 10.82 | ≈ 0 | < noise |
| `programs.jumphost.*` body | `modules/home/work/juspay.nix` | 9.51 → 9.56 | 0.05 | < noise |
| `claude-code` | `modules/home/claude-code` | 11.01 | ≈ 0 | < noise |
| `buildMachines` | `modules/home/nix/buildMachines*` | 10.89 | ≈ 0 | < noise |
| `incus`, `beszel`, `firefox`, `ttyd` | various | ≈ 10.85–10.92 | ≈ 0 | < noise |

Compound floors:

| drop | wall (s) | reduction |
|---|---:|---:|
| baseline | 10.87 | — |
| nixvim + vira + juspay + agenix (HM+NixOS) | 4.29 | −60.5 % |
| above + kolu | 3.85 | −64.6 % |

So the absolute lower bound (with these four heavies stubbed out) is
≈ 3.85 s — that's the cost of nixpkgs + home-manager + nixos-unified +
everything else combined.

The `home-manager.sharedModules` plumbing block in
`modules/nixos/common.nix` was probed independently: removing it left
the wall time unchanged (10.95 s ≈ 10.87 s), so the per-host HM-setup
boilerplate itself isn't a contributor.

## Optimization log

| # | hypothesis | mutation | wall (s) | Δ vs baseline | committed? | notes |
|---|---|---|---|---|---|---|
| 0 | — | baseline | 10.87 | — | — | reference |
| 1 | nixvim is 36 % of eval; the cost is the option system, not the resulting nvim binary | delete `inputs.nixvim` + the nixvim module; replace `modules/home/editors/neovim/` with a minimal `programs.neovim { enable; defaultEditor; vimAlias; viAlias; }` | **6.98** | **−3.89 s (−35.8 %)** | ✅ | 7-run median; range 7.73–6.94 (first-run warm-up jitter). Other configs (`naiveintent`, `infinitude-macos`, `srid@zest`) still eval cleanly. **Behaviour note:** nvim is now plain — none of the previous plugins (rose-pine, telescope, treesitter, lualine, noice, LSP keymaps, nvim-tree, lazygit, outline-nvim, mapleader) survive. User explicitly approved dropping nixvim. |

## Dead ends

(none yet)

## Key findings

(filled in at wrap-up)
