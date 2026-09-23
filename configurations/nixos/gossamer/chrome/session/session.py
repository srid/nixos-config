"""Restore Chrome once at Niri login, then remember open PWAs every five seconds."""

import fcntl
import importlib.util
import json
import os
from pathlib import Path
import signal
import sys
import threading


def capture(chrome):
    pid = chrome.browser_pid()
    # A failed IPC call must never replace a valid snapshot with an empty one.
    windows = chrome.windows()
    return {
        "browser": pid is not None and any(w.get("pid") == pid for w in windows),
        "apps": sorted(chrome.open_apps(windows, pid)),
    }


def save(path, snapshot):
    text = json.dumps(snapshot)
    if path.exists() and path.read_text() == text:
        return
    temporary = path.with_suffix(".tmp")
    temporary.write_text(text)
    temporary.chmod(0o600)
    temporary.replace(path)


def restore(chrome, snapshot):
    # On first activation or a service restart, leave the running browser alone.
    if snapshot.get("browser") and chrome.browser_pid() is None:
        chrome.restore({tuple(app) for app in snapshot["apps"]})


def main():
    spec = importlib.util.spec_from_file_location("restart_chrome", sys.argv[1])
    chrome = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(chrome)
    if not os.environ.get("NIRI_SOCKET"):
        raise RuntimeError("Chrome session restoration requires Niri.")
    state = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "chrome-session"
    state.mkdir(mode=0o700, parents=True, exist_ok=True)
    snapshot = state / "session.json"
    stop = threading.Event()
    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, lambda *_: stop.set())
    chrome.STATE.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Share the restart utility's lock: never save its temporarily closed PWAs.
    with (chrome.STATE / "lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            if snapshot.exists():
                restore(chrome, json.loads(snapshot.read_text()))
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)
        while not stop.is_set():
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                stop.wait(5)
                continue
            try:
                current = capture(chrome)
                if not stop.is_set():
                    save(snapshot, current)
            finally:
                fcntl.flock(lock, fcntl.LOCK_UN)
            stop.wait(5)
    # Do not save on shutdown: Niri may already be closing application windows.


if __name__ == "__main__":
    main()
