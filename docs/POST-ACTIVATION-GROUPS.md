# Picking up activation changes inside `systemd --user`

You ran `just activate`, then opened a new terminal via kolu, and
something you just configured — `incus-admin` group, a new `PATH`
entry, a `sessionVariable` — isn't there.

```
❯ id
uid=1000(srid) ... (no incus-admin)
```

## Why

`systemd --user` is a long-lived parent, started once by PID 1 as
`user@1000.service`. It snapshots groups, env, limits, and PAM state
at that start. Every child (kolu, and the PTYs kolu spawns) inherits
them. `linger = true` keeps the manager alive across logouts, so the
snapshot can be days old.

Restarting an individual unit (`systemctl --user restart kolu`) picks
up changes that live *in* the unit file (`Environment=`, `LimitNOFILE=`,
etc.), because those are applied per-start. It does **not** refresh
anything inherited from the manager.

## What's affected

Anything baked into a process at `fork+exec`:

| Setting                                             | Refreshed by |
|-----------------------------------------------------|--------------|
| Group membership (`users.users.*.extraGroups`)      | manager restart |
| `PATH`, `home.sessionVariables`, `/etc/environment` | manager restart |
| `systemd.user.sessionVariables`                     | manager restart |
| Resource limits, capabilities, PAM state            | manager restart |
| Per-unit `Environment=`, `LimitXYZ=`                | unit restart   |

Interactive shells get a fresh snapshot from PAM (`sudo su - srid`,
fresh `ssh`) — enough for running `incus` by hand, but useless for
kolu, vira, or anything spawned by the long-lived user manager.

## Fix

Recycle the user manager. Do it from a side channel, since it'll kill
kolu:

```sh
ssh srid@pureintent.tail12b27.ts.net     # bypass kolu
sudo systemctl restart user@$(id -u).service
```

Your SSH survives (it's a system session). Linger brings kolu back.
New PTYs have the fresh snapshot.

A reboot does the same thing with less ceremony.

## Verify

```sh
cat /proc/$(pgrep -u "$(id -u)" -f 'systemd --user')/status | grep -E 'Groups|^Uid'
```

The `Groups:` line should list the new GIDs (`incus` / `incus-admin`
show up as `984 985`). Then open a new kolu terminal and check `id`.
