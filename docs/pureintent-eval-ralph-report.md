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
| 2a | jumphost-nix module is ~1.5 s | inline `${jumphost-nix}/module.nix` into `juspay.nix` (drop input, hard-code values, drop devbox.nix's port-option read) | 7.03 | +0.05 (noise) | ❌ | The shallow drilldown was misleading (eval-error truncation). The cost moves; it doesn't disappear. Reverted. |
| 2b | vira HM module is ~1.3 s | inline `inputs.vira.homeManagerModules.vira` into `vira.nix` as direct `systemd.user.services.vira` + `age.secrets` | 6.94 | -0.04 (noise) | ❌ | Same explanation as 2a. Reverted. |
| 2c | unused flake inputs accumulate cost | drop `llm-agents` (literally only commented-out reference) | 7.01 | +0.02 (noise) | ❌ | Lazy inputs don't contribute. Reverted. |
| 2d | flake-parts modules add overhead | drop `claude-sandboxed.nix`, `devshell.nix`, `landrun-nix` | 6.91–6.99 | ≤0.06 (noise) | ❌ | Reverted. |
| 2e | `programs.ssh.matchBlocks` is the systemd-style cost driver | strip `controlpersist.nix` (3 matchBlocks) | 7.00 | +0.01 (noise) | ❌ | matchBlocks aren't the contributor either; the cost is the **per-entry merge** that pureintent has anyway via devbox.nix's `pu-jumphost` etc. Reverted. |
| 2f | nixos-unified's `autoWire` is overhead | replace with a hand-rolled `flake.nixosConfigurations.pureintent = mkLinuxSystem …` | ERR | — | ❌ | Pureintent itself reaches into `self.nixosModules.default` (created by autoWire), so a useful comparison needs reproducing the auto-wired attrsets first — out of scope. |

## Final measurement

7 warm runs, eval-cache disabled, `nixos-rebuild dry-build .#pureintent`,
on `optimize-eval` HEAD (cycle 1 applied):

| run | seconds |
|----:|--------:|
| 1   | 7.00 |
| 2   | 7.01 |
| 3   | 6.94 |
| 4   | 6.99 |
| 5   | 6.97 |
| 6   | 7.01 |
| 7   | 6.94 |

**Median: 6.99 s** &middot; range 6.94–7.01 (≈ 1 %).

| | wall (s) | Δ |
|---|---:|---:|
| baseline | 10.87 | — |
| after cycle 1 | **6.99** | **−3.88 s (−35.7 %)** |

Three other configurations continue to evaluate cleanly:
`nixosConfigurations.naiveintent`,
`darwinConfigurations.infinitude-macos`,
`homeConfigurations."srid@zest"`.

## Dead ends

All of the following were tried after cycle 1 and produced **no
measurable improvement** (≤ noise floor). Reported here so they don't
have to be re-tried.

- **Inline `${jumphost-nix}/module.nix`** into `juspay.nix`. Replaced the
  152-line work-jump-host module with an equivalent inline
  `programs.ssh.matchBlocks` / `systemd.user.services` /
  `programs.git.includes`. Result: 7.03 s — within noise. Earlier
  drilldown numbers that suggested ~1.5 s of jumphost-nix cost were
  *eval-error truncation* (devbox.nix references
  `programs.jumphost.socks5Proxy.port` and aborted eval before the rest
  of pureintent was processed). The real cost is in the resulting
  submodule materialisation (programs.ssh.matchBlocks, etc.), which is
  the same whether the values arrive via a wrapper module or a literal.

- **Inline `inputs.vira.homeManagerModules.vira`**. 167-line option
  schema + submodule replaced with a hand-rolled
  `systemd.user.services.vira` and `age.secrets` block.
  Result: 6.94 s — within noise. Same explanation as above.

- **Inline `inputs.kolu.homeManagerModules.default`**. Similar pattern;
  eval errored when `services.kolu.host` setter outlived the option
  declaration. With downstream-fix, expected zero benefit by the same
  argument.

- **Prune `inputs.llm-agents`** (only reference was already commented
  out). Result: 7.01 s — within noise.

- **Drop `modules/flake-parts/claude-sandboxed.nix`** (landrun-nix
  consumer at the flake-parts level). Result: 6.91 s — within noise.

- **Drop `modules/flake-parts/devshell.nix`** at flake-parts level.
  Result: 6.99 s — within noise.

- **Drop `landrun-nix` input + `claude-sandboxed.nix`**. Result:
  6.97 s — within noise.

- **Strip `modules/home/cli/controlpersist.nix`** entirely (3
  `programs.ssh.matchBlocks` entries). Result: 7.00 s — within noise.

- **Replace `nixos-unified.flakeModules.autoWire`** with a manual
  `flake.nixosConfigurations.pureintent = mkLinuxSystem …` — errors,
  because pureintent's own `default.nix` reaches into
  `self.nixosModules.default` which autoWire is responsible for
  creating. Measuring nixos-unified's residual overhead would require
  reproducing the auto-wired module attrsets by hand; not worth the
  effort given everything else has plateaued.

## Why we plateau at ~7 s

After cycle 1, the post-mortem profile (each "drop X" probe is run with
all *downstream consumers stubbed out* so the measurement isn't
eval-error-truncated):

| component | wall when dropped | Δ saved |
|---|---:|---:|
| (post-cycle-1 baseline) | 6.99 | — |
| `vira` HM module | ≈ 5.71 | 1.28 |
| `kolu` HM module | ≈ 6.49 | 0.50 |
| jumphost-nix module + body | (cannot measure cleanly; ~1.3 cost is real but inlining gives it back) | — |
| home CLI modules (tmux, starship, terminal, git, direnv, just, npm, nix-index-database, ttyd) | ≈ 0 each, ≈ 0.4 s cumulative | — |
| `agenix` (NixOS + HM) | ≈ 0 | — |
| `claude-code`, `buildMachines`, `incus`, `beszel`, `firefox`, `pipewire` | ≈ 0 each | — |

The remaining ≈ 4 s is the cost of evaluating nixpkgs `lib`, the NixOS
module system, home-manager's option universe, and `nixos-unified`'s
auto-wiring — together they are the irreducible floor for any host that
uses this flake.

The HM modules that *are* expensive (vira, kolu, jumphost-nix) cost what
they cost because their values land in
`systemd.user.services.<name>` or `programs.ssh.matchBlocks.<name>`,
each of which forces a per-entry home-manager submodule. Inlining the
wrapper module doesn't help because the merge is the same on either
side. The only way to reclaim that time is to (a) drop the service /
the matchBlock entirely, or (b) write the unit / ssh_config file
directly via `home.file` / `xdg.configFile` and bypass home-manager's
own ssh and systemd modules across the whole user — a much larger
refactor than fit inside this PR's scope.

## Key findings

1. **nixvim is 36 % of pureintent's eval time.** Its
   home-manager-style options module materialises hundreds of plugin
   submodules every eval. Cycle 1 dropped it (user-approved behaviour
   change to plain `programs.neovim`) and reclaimed 3.88 s.
2. **HM submodule materialisation, not option-declaration count, is the
   driver.** Inlining wrapper modules (jumphost-nix, vira) gives the
   work-saving illusion in shallow probes but no real saving because
   `systemd.user.services` and `programs.ssh.matchBlocks` re-do the
   same submodule work regardless of where their values came from.
3. **Unused flake inputs cost essentially nothing** at pureintent
   eval-time; flake inputs are lazy and only inputs reached
   transitively from `nixosConfigurations.pureintent` contribute.
4. **Eval-error-truncated probes look like wins.** Any "drop X" probe
   where a downstream module reads X's option silently shortens the
   eval and lies about its cost. Always validate probes succeed (we
   started checking exit codes after the jumphost-nix dead end).

## Methodology cost

- 1 successful commit + push (cycle 1).
- ≈ 50 probe runs on `srid-nc` over the cycle (3-run medians of dry-build).
- 1 draft PR open: <https://github.com/srid/nixos-config/pull/117>.
