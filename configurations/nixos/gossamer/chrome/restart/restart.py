"""Restart the normal Chrome profile and its open Niri PWAs using today's launcher."""

import argparse
import fcntl
import json
import os
from pathlib import Path
import re
import select
import signal
import socket
import subprocess
import sys
import time

CHROME = "/run/current-system/sw/bin/google-chrome"
APP_ID = re.compile(r"chrome-([a-p]{32})-(.+)")
DATA = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "google-chrome"
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "restart-chrome"


def windows():
    return json.loads(subprocess.check_output(["niri", "msg", "--json", "windows"]))


def browser_pid():
    try:
        host, raw_pid = os.readlink(DATA / "SingletonLock").rsplit("-", 1)
    except FileNotFoundError:
        return None
    if host != socket.gethostname():
        raise RuntimeError("Chrome's profile is locked by another host.")
    pid = int(raw_pid)
    proc = Path("/proc") / str(pid)
    try:
        exe = os.readlink(proc / "exe")
        owner = proc.stat().st_uid
    except FileNotFoundError:
        return None
    if owner != os.getuid() or not exe.endswith("/chrome") or "google-chrome-" not in exe:
        raise RuntimeError("The profile lock does not identify your Chrome browser.")
    return pid


def open_apps(items, pid):
    """Only PWAs belonging to this browser, never another user-data directory."""
    apps = set()
    for window in items:
        if window.get("pid") != pid:
            continue
        match = APP_ID.fullmatch(window.get("app_id") or "")
        if match:
            app, profile = match.groups()
            if not profile or Path(profile).name != profile:
                raise RuntimeError("Unrecognized Chrome profile directory.")
            apps.add((app, profile))
    return apps


def stop_browser(pid, timeout=30):
    # A pidfd prevents accidentally signalling a reused process ID. Recheck
    # the profile lock after opening it. Chrome handles SIGTERM gracefully.
    fd = os.pidfd_open(pid)
    try:
        if browser_pid() != pid:
            raise RuntimeError("Chrome changed while preparing the restart; try again.")
        signal.pidfd_send_signal(fd, signal.SIGTERM)
        if not select.select([fd], [], [], timeout)[0]:
            raise RuntimeError("Chrome has not exited. No force-kill was attempted; retry with --restore after it exits.")
    finally:
        os.close(fd)


def launch(*args):
    # Absolute system path picks up the latest activated wrapper and its flags.
    subprocess.Popen(
        [CHROME, *args], start_new_session=True,
        stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        close_fds=True,
    )


def restore(apps, timeout=20):
    if browser_pid() is None:
        launch("--restore-last-session")
    # Let Chrome restore its own app windows before supplying missing PWAs.
    deadline = time.monotonic() + timeout
    previous = None
    stable_since = time.monotonic()
    while time.monotonic() < deadline:
        pid = browser_pid()
        current = windows()
        signature = {(w["id"], w.get("app_id")) for w in current if w.get("pid") == pid}
        if signature != previous:
            previous, stable_since = signature, time.monotonic()
        if signature and time.monotonic() - stable_since >= 3:
            break
        time.sleep(0.25)
    else:
        raise RuntimeError("Chrome did not finish opening. Unlock KWallet if prompted, then run restart-chrome --restore.")
    missing = set(apps) - open_apps(current, pid)
    for app, profile in sorted(missing):
        launch(f"--profile-directory={profile}", f"--app-id={app}")
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if set(apps) <= open_apps(windows(), browser_pid()):
            return
        time.sleep(0.25)
    raise RuntimeError("Some PWAs did not reopen. Retry with restart-chrome --restore.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true", help="show detected apps without closing Chrome")
    mode.add_argument("--restore", action="store_true", help="retry reopening apps from the last snapshot")
    args = parser.parse_args()
    if not os.environ.get("NIRI_SOCKET"):
        raise RuntimeError("Run this action inside your Niri session.")
    if args.dry_run:
        pid = browser_pid()
        print(json.dumps({"browser_pid": pid, "apps": sorted(open_apps(windows(), pid)), "launcher": CHROME}, indent=2))
        return
    STATE.mkdir(mode=0o700, parents=True, exist_ok=True)
    with (STATE / "lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError("A Chrome restart is already in progress.") from None
        snapshot = STATE / "session.json"
        if args.restore:
            apps = {tuple(app) for app in json.loads(snapshot.read_text())}
        else:
            pid = browser_pid()
            if pid is None:
                raise RuntimeError("Chrome is not running; use --restore to retry the previous snapshot.")
            apps = open_apps(windows(), pid)
            temporary = snapshot.with_suffix(".tmp")
            temporary.write_text(json.dumps(sorted(apps)))
            temporary.chmod(0o600)
            temporary.replace(snapshot)
            stop_browser(pid)
        restore(apps)
        subprocess.run(["notify-send", "Chrome restarted", f"Restored Chrome and {len(apps)} web apps."], check=False)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"restart-chrome: {error}", file=sys.stderr)
        subprocess.run(["notify-send", "--urgency=critical", "Chrome restart", str(error)], check=False)
        sys.exit(1)
