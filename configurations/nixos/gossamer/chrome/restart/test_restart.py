"""Checks for browser targeting and restart recovery without touching live Chrome."""

import importlib.util
from pathlib import Path
import signal
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("restart_chrome", Path(__file__).with_name("restart.py"))
restart = importlib.util.module_from_spec(spec)
spec.loader.exec_module(restart)
APP = "a" * 32
OTHER = "b" * 32


class RestartTests(unittest.TestCase):
    def test_snapshot_excludes_other_browser_and_non_app_windows(self):
        windows = [
            {"pid": 42, "app_id": f"chrome-{APP}-Profile 1"},
            {"pid": 42, "app_id": f"chrome-{APP}-Profile 1"},
            {"pid": 99, "app_id": f"chrome-{OTHER}-Default"},
            {"pid": 42, "app_id": "google-chrome"},
            {"pid": 42, "app_id": None},
        ]
        self.assertEqual(restart.open_apps(windows, 42), {(APP, "Profile 1")})

    def test_changed_browser_is_not_signalled(self):
        with patch.object(restart.os, "pidfd_open", return_value=10), \
             patch.object(restart.os, "close"), \
             patch.object(restart, "browser_pid", return_value=99), \
             patch.object(restart.signal, "pidfd_send_signal") as send:
            with self.assertRaisesRegex(RuntimeError, "Chrome changed"):
                restart.stop_browser(42)
            send.assert_not_called()

    def test_shutdown_timeout_never_force_kills(self):
        with patch.object(restart.os, "pidfd_open", return_value=10), \
             patch.object(restart.os, "close"), \
             patch.object(restart, "browser_pid", return_value=42), \
             patch.object(restart.select, "select", return_value=([], [], [])), \
             patch.object(restart.signal, "pidfd_send_signal") as send:
            with self.assertRaisesRegex(RuntimeError, "No force-kill"):
                restart.stop_browser(42)
            send.assert_called_once_with(10, signal.SIGTERM)

    def test_restore_only_launches_missing_apps(self):
        current = [{"id": 1, "pid": 42, "app_id": f"chrome-{APP}-Default"}]

        def launch(*args):
            self.assertEqual(args, ("--profile-directory=Profile 1", f"--app-id={OTHER}"))
            current.append({"id": 2, "pid": 42, "app_id": f"chrome-{OTHER}-Profile 1"})

        ticks = iter(range(100))
        with patch.object(restart, "browser_pid", return_value=42), \
             patch.object(restart, "windows", side_effect=lambda: list(current)), \
             patch.object(restart.time, "monotonic", side_effect=lambda: next(ticks)), \
             patch.object(restart.time, "sleep"), \
             patch.object(restart, "launch", side_effect=launch) as start:
            restart.restore({(APP, "Default"), (OTHER, "Profile 1")})
            self.assertEqual(start.call_count, 1)


if __name__ == "__main__":
    unittest.main()
