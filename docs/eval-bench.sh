#!/usr/bin/env bash
# Ralph eval-time benchmark — counter-based.
# Usage: ralph-bench.sh [target]   target = pureintent | sincereintent | (both)
#
# Primary metric: deterministic eval-work counters from NIX_SHOW_STATS:
#   nrThunks, nrFunctionCalls, nrPrimOpCalls.
# These are byte-identical across runs (independent of CPU clock/load), so a
# single eval gives an exact number. cpuTime is NOT used: this machine thermally
# throttles, inflating CPU-seconds for identical work (11s..21s for one eval).
# Eval cache disabled; fetcher cache warm via persistent $HOME.
set -uo pipefail

export HOME=/tmp/ralph-evalhome
mkdir -p "$HOME"
FLAKE="${FLAKE:-/home/srid/code/nixos-config/.worktrees/ralph}"
ONLY="${1:-}"

declare -A ATTR
ATTR[pureintent]="$FLAKE#nixosConfigurations.pureintent.config.system.build.toplevel.drvPath"
ATTR[sincereintent]="$FLAKE#homeConfigurations.\"srid@sincereintent\".activationPackage.drvPath"

num() { grep -o "\"$1\": [0-9.]*" /tmp/ralph-stats.json | grep -o '[0-9.]*' | head -1; }

for target in pureintent sincereintent; do
  [ -n "$ONLY" ] && [ "$ONLY" != "$target" ] && continue
  NIX_SHOW_STATS=1 nix eval --raw "${ATTR[$target]}" --option eval-cache false \
    >/dev/null 2>/tmp/ralph-stats.json
  if [ $? -ne 0 ]; then echo "$target FAILED"; tail -8 /tmp/ralph-stats.json; exit 1; fi
  printf '%-11s thunks=%-10s calls=%-10s primops=%-9s | values=%s sets=%s\n' \
    "$target" "$(num nrThunks)" "$(num nrFunctionCalls)" "$(num nrPrimOpCalls)" \
    "$(num number)" "$(grep -o '"sets": {[^}]*"number": [0-9]*' /tmp/ralph-stats.json | grep -o '[0-9]*$')"
done
