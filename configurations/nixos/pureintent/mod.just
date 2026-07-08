# Pureintent-specific operational recipes.
#
# Imported from the top-level Justfile. Each recipe bakes in the values
# that are stable on this host (tailscale IP, container names, port
# choices) so the day-to-day operator just types `just anywhen-deploy`,
# not the full incus-pet invocation.

LISTEN_IP := "100.122.32.106"  # pureintent's tailscale IP

# ----------------------------------------------------------------------
# anywhen — github:srid/anywhen as a per-app incus-pet container.
# ----------------------------------------------------------------------

# Deploy anywhen (default: master); pass `ref` to deploy a branch/PR.
[group('anywhen')]
anywhen-deploy ref="github:srid/anywhen":
    nix run .#incus-pet -- deploy {{ ref }} anywhen --port 6111 --listen {{ LISTEN_IP }}

# Drop the anywhen container entirely (state goes with it — back up first).
[group('anywhen')]
anywhen-rm:
    nix run .#incus-pet -- rm anywhen

# Pull a WAL-checkpointed snapshot of the live SQLite DB to PATH.
[group('anywhen')]
anywhen-backup path="/tmp/anywhen.db":
    incus exec anywhen -- systemctl stop anywhen.service
    incus exec anywhen -- sh -c 'cd /var/lib/private/anywhen && sqlite3 anywhen.db "PRAGMA wal_checkpoint(TRUNCATE);" 2>/dev/null || true'
    incus file pull anywhen/var/lib/private/anywhen/anywhen.db {{ path }}
    incus exec anywhen -- systemctl start anywhen.service
    @echo "backup -> {{ path }}"

# Push a DB file into the anywhen container (stop/copy/chown/wipe-wal/start).
[group('anywhen')]
anywhen-restore db:
    incus exec anywhen -- systemctl stop anywhen.service
    incus file push {{ db }} anywhen/var/lib/private/anywhen/anywhen.db --mode 644
    incus exec anywhen -- sh -c 'chown $(stat -c "%u:%g" /var/lib/private/anywhen) /var/lib/private/anywhen/anywhen.db'
    incus exec anywhen -- rm -f /var/lib/private/anywhen/anywhen.db-wal /var/lib/private/anywhen/anywhen.db-shm
    incus exec anywhen -- systemctl start anywhen.service
    @echo "restored {{ db }} -> anywhen.service active"

# Health check (curl /api/health, in-container service status, full list).
[group('anywhen')]
anywhen-status:
    @echo "--- tailnet ---"
    @curl -sS http://{{ LISTEN_IP }}:6111/api/health && echo
    @echo "--- container ---"
    @incus exec anywhen -- systemctl is-active anywhen.service
    @nix run .#incus-pet -- list

# Drop into a root shell inside the anywhen container.
[group('anywhen')]
anywhen-shell:
    incus exec anywhen -- bash
