# pureintent vs naiveintent — which to use for dev + agentic work

Both are AMD Zen 4 (Phoenix) 8c/16t boxes, so CPU is nearly a wash. The
real differences are **RAM, SSD, and form factor**. All numbers below
were measured directly on each machine (June 2026).

## Measured comparison

| | **pureintent** (Beelink SER8) | **naiveintent** (Lenovo ThinkPad 21ME) |
|---|---|---|
| CPU | Ryzen 7 **8845HS**, 8c/16t | Ryzen 7 PRO **8840HS**, 8c/16t |
| Sustained all-core clock | **4.59 GHz** | 4.27 GHz |
| Single-core throughput | ~4.55 GB/s sha (tie) | ~4.70 GB/s sha (tie) |
| RAM | 32 GB — 20 GB free, **already swapping (5.5 GB)** | **64 GB** — 55 GB free, 0 swap |
| SSD | Crucial P3 Plus (QLC, **DRAM-less**) | KIOXIA KXG8 (premium TLC) |
| Sustained write (4 GB, fdatasync) | **729 MB/s** | **3.1 GB/s** (4.3×) |
| Sequential read (direct) | 5.3 GB/s | 3.2 GB/s (through LUKS) |
| Free disk | 200 GB (**77% full**) | 782 GB (13% full) |
| Encryption | none | LUKS full-disk |
| Form factor | always-on mini PC | laptop (battery, lid, roams) |

Both run the `powersave` governor with `balance_performance` EPP
(amd-pstate active mode — normal, not a real powersave), so that's not
a differentiator.

## What it means

- **CPU: a wash.** Same silicon. pureintent holds ~7% higher *sustained*
  all-core clock (mini-PC cooling beats a thin laptop chassis), so large
  parallel Nix builds finish marginally faster on it. Single-core /
  interactive latency is a tie. Not a deciding factor.
- **RAM strongly favors naiveintent (2×).** This is what bites agentic
  work — several Claude Code agents + language servers + builds + a
  browser + incus containers eat RAM fast. pureintent already dips into
  swap at light load; naiveintent has 55 GB free.
- **Disk strongly favors naiveintent.** 4.3× faster sustained writes and
  6× more free space, on a better drive. Agentic/dev I/O is write-heavy
  (nix store, git, node_modules, compile artifacts, logs). pureintent's
  QLC + DRAM-less drive at 77% full only degrades further. LUKS on
  naiveintent is effectively free (AES-NI).

## Verdict

For *doing* heavy interactive + agentic work, **naiveintent wins
clearly** — 2× RAM and 4× write throughput dwarf pureintent's ~7%
multi-core edge.

The only caveat was form factor: a laptop that sleeps/roams makes a poor
always-on host for a service like Kolu. **naiveintent will be deployed
always-on and plugged in**, so that caveat is moot → **migrate to
naiveintent.**

## Migration notes

naiveintent's config is currently near-empty (`kolu` + `gc`); pureintent
carries the workhorse stack. To port the setup from
`configurations/nixos/pureintent/default.nix`:

- **Kolu** — `services.kolu.host = "naiveintent"` is already set. Revisit
  `allowedOrigins` (pureintent allows its Tailscale MagicDNS origin) and
  any Tailscale-IP binding.
- **home-manager shared modules** naiveintent lacks: `ssh-agent-forwarding`,
  `controlpersist`, `claude-code`, `work/juspay.nix`, `services/vira.nix`,
  `services/drishti`.
- **incus** stack (`beszel.nix`, `incus`) + the `core.https_address`
  preseed, if you want anywhen/containers and the incus UI.
- **remote builders** (`buildMachines` + `sincereintent.nix`).
- the dbus-broker / NetworkManager-wait-online activation workarounds.

Won't move cleanly:

- **drishti** CI-fleet monitoring depends on pureintent-local ssh aliases
  (`pu`-managed `ssh_config`, `kolu-ci-1..8`, reachable only from
  pureintent). Either keep drishti on pureintent or move the `pu` state.
- Decide whether pureintent is decommissioned or kept as a secondary
  builder.

Regardless of the outcome: **GC pureintent** — at 77% full on a degrading
QLC drive it needs headroom.
