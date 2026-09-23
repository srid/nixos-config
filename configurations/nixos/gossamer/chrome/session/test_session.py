import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock

import session


class SessionTests(unittest.TestCase):
    def test_background_browser_without_windows_is_not_saved_as_open(self):
        chrome = Mock()
        chrome.browser_pid.return_value = 123
        chrome.windows.return_value = [{"pid": 456, "app_id": "foot"}]
        chrome.open_apps.return_value = set()
        self.assertEqual(session.capture(chrome), {"browser": False, "apps": []})

    def test_running_browser_is_not_reopened(self):
        chrome = Mock()
        chrome.browser_pid.return_value = 123
        session.restore(chrome, {"browser": True, "apps": [["app", "Default"]]})
        chrome.restore.assert_not_called()

    def test_saved_apps_return_on_fresh_login(self):
        chrome = Mock()
        chrome.browser_pid.return_value = None
        session.restore(chrome, {"browser": True, "apps": [["app", "Default"]]})
        chrome.restore.assert_called_once_with({("app", "Default")})

    def test_intentionally_closed_browser_stays_closed(self):
        chrome = Mock()
        session.restore(chrome, {"browser": False, "apps": []})
        chrome.restore.assert_not_called()

    def test_ipc_failure_preserves_previous_snapshot(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "session.json"
            original = {"browser": True, "apps": [["app", "Default"]]}
            session.save(path, original)
            chrome = Mock()
            chrome.windows.side_effect = RuntimeError("Niri stopped")
            with self.assertRaises(RuntimeError):
                session.save(path, session.capture(chrome))
            self.assertEqual(json.loads(path.read_text()), original)
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)


if __name__ == "__main__":
    unittest.main()
