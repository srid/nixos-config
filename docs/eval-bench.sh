#!/usr/bin/env bash
# Ralph eval-time benchmark.
# Usage: ralph-bench.sh <runs>
# Primary metric: median cpuTime (NIX_SHOW_STATS) — stable, isolates eval work.
# Secondary: median wall-clock (noisy, IO-bound).
# Eval cache disabled; fetcher cache warm via persistent $HOME.
set -uo pipefail

RUNS="${1:-5}"
export HOME=/tmp/ralph-evalhome
mkdir -p "$HOME"
FLAKE="${FLAKE:-/home/srid/code/nixos-config/.worktrees/ralph}"

declare -A ATTR
ATTR[pureintent]="$FLAKE#nixosConfigurations.pureintent.config.system.build.toplevel.drvPath"
ATTR[zest]="$FLAKE#homeConfigurations.\"srid@zest\".activationPackage.drvPath"

median() { sort -n | awk '{a[NR]=$1} END{ if(NR%2){print a[(NR+1)/2]} else {print (a[NR/2]+a[NR/2+1])/2} }'; }
now_ms() { date +%s%3N; }

for target in pureintent zest; do
  attr="${ATTR[$target]}"
  cpus=(); walls=()
  for i in $(seq 1 "$RUNS"); do
    start=$(now_ms)
    NIX_SHOW_STATS=1 nix eval --raw "$attr" --option eval-cache false \
      >/dev/null 2>/tmp/ralph-stats.json
    rc=$?
    end=$(now_ms)
    if [ $rc -ne 0 ]; then echo "$target run $i FAILED (rc=$rc)"; tail -8 /tmp/ralph-stats.json; exit 1; fi
    cpu=$(grep -o '"cpuTime": [0-9.]*' /tmp/ralph-stats.json | head -1 | grep -o '[0-9.]*')
    cpus+=("$cpu"); walls+=("$((end - start))")
  done
  medcpu=$(printf '%s\n' "${cpus[@]}" | median)
  medwall=$(printf '%s\n' "${walls[@]}" | median)
  medwall_s=$(awk "BEGIN{printf \"%.2f\", $medwall/1000}")
  printf '%-11s cpuTime=%ss (median of %d) | wall=%ss | cpu=[%s] wall_ms=[%s]\n' \
    "$target" "$medcpu" "$RUNS" "$medwall_s" "${cpus[*]}" "${walls[*]}"
done
