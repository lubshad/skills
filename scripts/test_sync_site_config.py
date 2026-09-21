"""Isolated checks; never contact a server or restore a real site."""

import base64
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


HELPER = Path(__file__).with_name("sync_site_config.py")
SCRIPT = Path(__file__).with_name("sync_server_data.sh")
spec = importlib.util.spec_from_file_location("sync_site_config", HELPER)
config = importlib.util.module_from_spec(spec)
spec.loader.exec_module(config)
KEY = base64.urlsafe_b64encode(b"x" * 32).decode()


class ConfigSyncTests(unittest.TestCase):
	def test_allowlist_and_protection(self) -> None:
		remote = {"encryption_key": KEY, "custom_token": "secret", "db_password": "production"}
		self.assertEqual(config.selected_config(remote, []), {"encryption_key": KEY})
		self.assertEqual(config.selected_config(remote, ["custom_token"])["custom_token"], "secret")
		for key in ["db_password", "redis_cache", "host_name", "developer_mode", "pause_scheduler"]:
			with self.assertRaises(ValueError):
				config.selected_config({**remote, key: "production"}, [key])
		for remote in [{}, {"encryption_key": "invalid"}, {"encryption_key": None}]:
			with self.assertRaises(ValueError):
				config.selected_config(remote, [])

	def test_backup_and_atomic_merge(self) -> None:
		with tempfile.TemporaryDirectory() as directory:
			root = Path(directory)
			remote = root / "remote.json"
			local = root / "site_config.json"
			remote.write_text(json.dumps({"encryption_key": KEY, "custom_token": "secret", "db_name": "production"}))
			original = {"db_name": "local", "db_password": "local-password", "developer_mode": 1}
			local.write_text(json.dumps(original))
			args = ["--remote", str(remote), "--local", str(local), "--key", "custom_token"]
			for action in ["validate", "backup", "apply"]:
				result = subprocess.run(["python3", str(HELPER), action, *args], capture_output=True, text=True)
				self.assertEqual(result.returncode, 0, result.stderr)
				self.assertNotIn("secret", result.stdout)
			self.assertEqual(json.loads(local.read_text()), {**original, "encryption_key": KEY, "custom_token": "secret"})
			backup = next(root.glob("site_config.pre-sync-*.json"))
			self.assertEqual(json.loads(backup.read_text()), original)
			for path in [local, backup]:
				self.assertEqual(path.stat().st_mode & 0o777, 0o600)

	def test_invalid_and_new_site_validation(self) -> None:
		with tempfile.TemporaryDirectory() as directory:
			root = Path(directory)
			remote = root / "remote.json"
			local = root / "missing.json"
			for content, expected in [("[1]", 1), ('{"secret": broken}', 1), (json.dumps({"encryption_key": KEY}), 0)]:
				remote.write_text(content)
				result = subprocess.run(["python3", str(HELPER), "validate", "--remote", str(remote), "--local", str(local)], capture_output=True, text=True)
				self.assertEqual(result.returncode, expected)
				self.assertFalse(local.exists())
				self.assertNotIn("broken", result.stderr)

	def test_dry_run_has_no_side_effects(self) -> None:
		with tempfile.TemporaryDirectory() as directory:
			root = Path(directory)
			key = root / "key"
			key.touch()
			result = subprocess.run(["bash", str(SCRIPT), "--remote-site", "example.test", "--local-site", "local.test", "--local-bench", directory, "--ssh-key", str(key), "--mariadb-root-username", "root", "--mariadb-root-password", "fixture"], capture_output=True, text=True)
			self.assertEqual(result.returncode, 0, result.stderr)
			self.assertIn("configuration paired with the database", result.stdout)
			self.assertEqual(list(root.iterdir()), [key])

	def test_mocked_restore_sequence(self) -> None:
		for existing in [False, True]:
			with self.subTest(existing=existing), tempfile.TemporaryDirectory() as directory:
				root = Path(directory)
				bin_dir = root / "bin"
				bin_dir.mkdir()
				(root / "key").touch()
				local = root / "sites/local.test/site_config.json"
				if existing:
					local.parent.mkdir(parents=True)
					local.write_text('{"db_name":"local"}')
				commands = {
					"pgrep": "exit 0",
					"ssh": "case \"$*\" in *database.sql.gz*) printf '/remote/20260101-example_test-database.sql.gz\\n';; esac",
					"scp": '''source="${@: -2:1}"
destination="${@: -1}"
case "$source" in
*site_config_backup.json) printf '%s' "$REMOTE_JSON" > "$destination";;
*) touch "$destination/$(basename "$source")";;
esac''',
					"bench": '''printf '%s\\n' "$*" >> "$MOCK_ROOT/events"
if [[ "$1" == new-site ]]; then
  mkdir -p "$MOCK_ROOT/sites/local.test"
  printf '{"db_name":"local"}' > "$MOCK_ROOT/sites/local.test/site_config.json"
fi
if [[ "$*" == *restore* ]]; then
  compgen -G "$MOCK_ROOT/sites/local.test/site_config.pre-sync-*.json" >/dev/null || exit 9
fi
if [[ "$*" == *migrate* ]]; then
  python3 -c 'import json,os; assert json.load(open(os.environ["MOCK_ROOT"]+"/sites/local.test/site_config.json"))["encryption_key"]'
fi''',
				}
				for name, body in commands.items():
					path = bin_dir / name
					path.write_text("#!/usr/bin/env bash\nset -e\n" + body + "\n")
					path.chmod(0o700)
				env = {**os.environ, "PATH": f"{bin_dir}:{os.environ['PATH']}", "MOCK_ROOT": directory, "REMOTE_JSON": json.dumps({"encryption_key": KEY, "db_name": "production"})}
				result = subprocess.run(["bash", str(SCRIPT), "--execute", "--skip-backup", "--skip-files", "--remote-site", "example.test", "--local-site", "local.test", "--local-bench", directory, "--ssh-key", str(root / "key"), "--mariadb-root-username", "root", "--mariadb-root-password", "fixture"], env=env, capture_output=True, text=True)
				self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
				self.assertEqual(json.loads(local.read_text()), {"db_name": "local", "encryption_key": KEY})


if __name__ == "__main__":
	unittest.main()
