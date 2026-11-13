"""Offline tests: no SSH connections or system configuration changes."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("setup_frappe_server.sh")
SCRATCH = Path.home() / ".local/share/opencode/disk-tmp/opencode"


class ProvisioningOnlyTest(unittest.TestCase):
    def test_removed_app_options_are_rejected_without_ssh(self):
        for option in ("--app", "--app-branch", "--install-app"):
            with self.subTest(option=option):
                result = subprocess.run(
                    ["bash", str(SCRIPT), option, "unused"],
                    capture_output=True, text=True,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(f"unknown argument: {option}", result.stderr)
                self.assertNotIn("Phase 1", result.stdout)

    def test_help_points_to_separate_app_script(self):
        result = subprocess.run(
            ["bash", str(SCRIPT), "--help"],
            capture_output=True, text=True, check=True,
        )
        self.assertIn("setup_frappe_supporting_apps.sh", result.stdout)
        for option in ("--app REPO", "--app-branch BRANCH", "--install-app APP"):
            self.assertNotIn(option, result.stdout)
        source = SCRIPT.read_text()
        self.assertNotIn("bench get-app", source)
        self.assertNotIn("install-app", source)


class AllowBenchUserSshTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        definitions = SCRIPT.read_text().split('while [[ $# -gt 0 ]]; do', 1)[0]
        cls.command = subprocess.run(
            ["bash", "-c", "source /dev/stdin"],
            input=definitions + "\nallow_bench_user_ssh_command\n",
            text=True,
            capture_output=True,
            check=True,
        ).stdout

    def run_case(self, config, failure=""):
        with tempfile.TemporaryDirectory(dir=SCRATCH) as directory:
            path = Path(directory)
            target = path / "sshd_config"
            target.write_text(config)
            mocks = r'''
set -euo pipefail
sshd() {
  if [ "$1" = -t ]; then
    if [ "$FAILURE" = validation ] && grep -q '^AllowUsers frappe$' "$TEST_PATH/sshd_config"; then
      return 1
    fi
  else
    awk 'tolower($1) == "allowusers" {$1="allowusers"; print}' "$TEST_PATH/sshd_config"
  fi
}
systemctl() {
  if [ "$1" = reload ]; then
    printf '%s\n' "$*" >> "$TEST_PATH/reloads"
    [ "$FAILURE" != reload ]
  fi
}
'''
            result = subprocess.run(
                ["bash"],
                input=mocks + self.command.replace("/etc/ssh/", directory + "/"),
                text=True,
                capture_output=True,
                env={**os.environ, "TEST_PATH": directory, "FAILURE": failure},
            )
            reloads = path / "reloads"
            return (
                result,
                target.read_text(),
                reloads.read_text() if reloads.exists() else "",
                list(path.glob("sshd_config.frappe-setup.*")),
            )

    def test_adds_user_and_preserves_existing_rules(self):
        original = "AllowUsers root lubshad\nMatch User root\n    PasswordAuthentication no\n"
        result, config, reloads, backups = self.run_case(original)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(config, "AllowUsers frappe\n" + original)
        self.assertEqual(reloads, "reload ssh\n")
        self.assertEqual(backups, [])

    def test_existing_user_is_unchanged(self):
        original = "AllowUsers root frappe\n"
        result, config, reloads, _ = self.run_case(original)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(config, original)
        self.assertEqual(reloads, "")

    def test_unrestricted_server_stays_unrestricted(self):
        original = "PubkeyAuthentication yes\n"
        result, config, reloads, _ = self.run_case(original)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(config, original)
        self.assertEqual(reloads, "")

    def test_validation_failure_restores_config_without_reload(self):
        original = "AllowUsers root\n"
        result, config, reloads, backups = self.run_case(original, "validation")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(config, original)
        self.assertEqual(reloads, "")
        self.assertEqual(backups, [])

    def test_reload_failure_restores_original_config(self):
        original = "AllowUsers root\n"
        result, config, reloads, backups = self.run_case(original, "reload")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(config, original)
        self.assertEqual(reloads, "reload ssh\nreload ssh\n")
        self.assertEqual(backups, [])

    def test_check_runs_before_phase_two(self):
        script = SCRIPT.read_text()
        self.assertLess(
            script.index('remote_privileged "$(allow_bench_user_ssh_command)"'),
            script.index("printf 'Phase 2/3:"),
        )


if __name__ == "__main__":
    unittest.main()
