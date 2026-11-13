"""Offline tests. Never contact a server or run a real Bench command."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("setup_frappe_supporting_apps.sh")
SCRATCH = Path.home() / ".local/share/opencode/disk-tmp/opencode"


class SupportingAppsTest(unittest.TestCase):
    def cli(self, *args):
        return subprocess.run(
            ["bash", str(SCRIPT), *args], capture_output=True, text=True
        )

    def test_local_dry_run(self):
        result = self.cli(
            "--host", "ssh.sync-app.in", "--app", "flutter_utils",
            "--app", "agora_integration",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Dry-run only. No server connection", result.stdout)

    def test_git_branch_is_required(self):
        result = self.cli("--host", "example.com", "--git-app", "https://github.com/frappe/erpnext.git")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--branch is required", result.stderr)

    def test_mixed_dry_run(self):
        result = self.cli(
            "--host", "example.com", "--app", "flutter_utils",
            "--git-app", "https://github.com/frappe/erpnext.git",
            "--branch", "version-16", "--site", "example.com",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("branch version-16", result.stdout)

    def test_invalid_arguments(self):
        for args in [
            ["--host"],
            ["--host", "-bad", "--app", "flutter_utils"],
            ["--host", "example.com", "--app", "../frappe"],
            ["--host", "example.com", "--app", "flutter_utils", "--app", "flutter_utils"],
            ["--host", "example.com", "--branch", "main"],
            ["--host", "example.com", "--git-app", "https://user:secret@example.com/app", "--branch", "main"],
            ["--host", "example.com", "--app", "flutter_utils", "--ssh-port", "99999"],
        ]:
            with self.subTest(args=args):
                self.assertNotEqual(self.cli(*args).returncode, 0)

    @unittest.skipUnless(shutil.which("rsync"), "rsync required")
    def test_remote_local_lifecycle_offline(self):
        with tempfile.TemporaryDirectory(prefix="supporting-app-test-", dir=SCRATCH) as tmp:
            root = Path(tmp)
            bench = root / "bench"
            stage = bench / ".supporting-app-staging/run.test"
            (bench / "sites/example.com").mkdir(parents=True)
            (bench / "sites/example.com/site_config.json").write_text("{}")
            (bench / "sites/apps.txt").write_text("frappe")  # Missing newline.
            (bench / "env/bin").mkdir(parents=True)
            fakebin = root / "bin"
            fakebin.mkdir()
            log = root / "commands"
            fakebench = fakebin / "bench"
            fakebench.write_text(
                "#!/usr/bin/env python3\n"
                "import json, os, subprocess, sys\n"
                "from pathlib import Path\n"
                "with open(os.environ['TEST_LOG'], 'a') as f: f.write(' '.join(sys.argv[1:]) + '\\n')\n"
                "state = Path(os.environ['TEST_STATE'])\n"
                "apps = json.loads(state.read_text())\n"
                "if 'list-apps' in sys.argv: print(json.dumps({'example.com': apps}))\n"
                "if 'install-app' in sys.argv:\n"
                "    apps.append(sys.argv[-1]); state.write_text(json.dumps(apps))\n"
                "if 'get-app' in sys.argv:\n"
                "    url = sys.argv[-1]; name = url.rsplit('/', 1)[-1].removesuffix('.git')\n"
                "    branch = sys.argv[sys.argv.index('--branch') + 1]\n"
                "    subprocess.run(['git', 'clone', '--branch', branch, url, 'apps/' + name], check=True)\n"
                "    path = Path('sites/apps.txt')\n"
                "    path.write_text('\\n'.join(dict.fromkeys(path.read_text().split() + [name])) + '\\n')\n"
            )
            fakebench.chmod(0o755)
            python = bench / "env/bin/python"
            python.write_text(
                "#!/usr/bin/env bash\nset -e\n"
                "if [[ $1 == -m && $2 == pip ]]; then\n"
                "  echo \"$*\" >> \"$TEST_LOG\"\n"
                "else exec python3 \"$@\"; fi\n"
            )
            python.chmod(0o755)
            names = ["fixture_utils", "fixture_calls"]
            for name in names:
                package = stage / name / name
                package.mkdir(parents=True)
                (package / "__init__.py").write_text("")
                (package / "hooks.py").write_text(
                    "required_apps = " + repr([names[0]] if name == names[1] else [])
                )
                (package.parent / "pyproject.toml").write_text("[project]\nname = 'fixture'\n")
                run = package.parent / "run.sh"
                run.write_text("#!/bin/bash\nexit 0\n")
                run.chmod(0o755)
                (bench / "apps" / name).mkdir(parents=True)
                (bench / "apps" / name / "obsolete.py").write_text("old")
                (bench / "apps" / name / ".env").write_text("server-only")
            state = root / "installed.json"
            state.write_text(json.dumps(["frappe"]))
            text = SCRIPT.read_text()
            function = text.split("apply_remote() {", 1)[1].split("\n}\n{\n", 1)[0]
            # All paths below are generated temporary paths, not shell input.
            prefix = (
                f"BENCH={bench}\nSTAGE={stage}\nSITE=example.com\nBUILD=1\n"
                "NAMES=(fixture_utils fixture_calls)\nKINDS=(--app --app)\n"
                "EXCLUDES=(.git .env)\n"
            )
            env = dict(os.environ, HOME=str(root), PATH=f"{fakebin}:{os.environ['PATH']}",
                       TEST_LOG=str(log), TEST_STATE=str(state),
                       PYTHONPATH=":".join(str(bench / "apps" / n) for n in names))
            command = prefix + "apply_remote() {" + function + "\n}\napply_remote\n"
            result = subprocess.run(["bash"], input=command, text=True, capture_output=True, env=env)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual((bench / "sites/apps.txt").read_text(), "frappe\nfixture_utils\nfixture_calls\n")
            commands = log.read_text()
            self.assertLess(commands.index("backup --with-files"), commands.index("-m pip"))
            self.assertLess(commands.index("install-app fixture_utils"), commands.index("install-app fixture_calls"))
            self.assertEqual(commands.count(" migrate"), 1)
            self.assertEqual(commands.count("restart"), 1)
            for name in names:
                self.assertFalse((bench / "apps" / name / "obsolete.py").exists())
                self.assertEqual((bench / "apps" / name / ".env").read_text(), "server-only")
                self.assertTrue(os.access(bench / "apps" / name / "run.sh", os.X_OK))
                self.assertTrue((bench / ".supporting-app-backups/run.test" / f"{name}.tar.gz").is_file())
            # Rerunning updates packages, but must not reinstall existing site apps.
            log.write_text("")
            result = subprocess.run(["bash"], input=command, text=True, capture_output=True, env=env)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("install-app", log.read_text())
            # Dependency errors fail before backups, pip, migrations, or restart.
            (stage / names[0] / names[0] / "hooks.py").write_text("required_apps = ['missing_app']")
            log.write_text("")
            result = subprocess.run(["bash"], input=command, text=True, capture_output=True, env=env)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("requires missing_app", result.stderr)
            self.assertNotIn("backup", log.read_text())

            # Exercise public Git handling using a local URL rewrite. No network.
            repository = root / "fixture_git"
            repository.mkdir()
            def git(*args):
                return subprocess.run(
                    ["git", "-C", str(repository), *args], check=True,
                    capture_output=True, text=True,
                )
            git("init", "-b", "stable")
            package = repository / "fixture_git"
            package.mkdir()
            (package / "__init__.py").write_text("")
            (package / "hooks.py").write_text("required_apps = []")
            (repository / "pyproject.toml").write_text("[project]\nname = 'fixture_git'\n")
            git("add", ".")
            git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-m", "initial")
            env.update(
                GIT_CONFIG_COUNT="1",
                GIT_CONFIG_KEY_0=f"url.file://{root}/.insteadOf",
                GIT_CONFIG_VALUE_0="https://fixtures.example/",
                PYTHONPATH=str(bench / "apps/fixture_git"),
            )
            prefix = (
                f"BENCH={bench}\nSTAGE={stage}\nSITE=''\nBUILD=0\n"
                "NAMES=(fixture_git)\nKINDS=(--git-app)\n"
                "SOURCES=(https://fixtures.example/fixture_git)\n"
                "BRANCHES=(stable)\nEXCLUDES=(.git .env)\n"
            )
            command = prefix + "apply_remote() {" + function + "\n}\napply_remote\n"
            log.write_text("")
            result = subprocess.run(["bash"], input=command, text=True, capture_output=True, env=env)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("get-app --branch stable --skip-assets https://fixtures.example/fixture_git", log.read_text())
            self.assertNotIn("-m pip", log.read_text())
            self.assertIn("fixture_git\n", (bench / "sites/apps.txt").read_text())
            # A second commit is fast-forwarded into the existing server checkout.
            (package / "update.py").write_text("updated = True")
            git("add", ".")
            git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-m", "update")
            # Each real CLI invocation creates a fresh staging directory.
            update_stage = bench / ".supporting-app-staging/run.update"
            update_stage.mkdir()
            command = command.replace(f"STAGE={stage}\n", f"STAGE={update_stage}\n")
            log.write_text("")
            result = subprocess.run(["bash"], input=command, text=True, capture_output=True, env=env)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("get-app", log.read_text())
            self.assertIn("-m pip install -e apps/fixture_git", log.read_text())
            self.assertTrue((bench / "apps/fixture_git/fixture_git/update.py").exists())
            # New staging path for a subsequent attempt, as used by the real CLI.
            stage2 = bench / ".supporting-app-staging/run.next"
            stage2.mkdir()
            command = command.replace(f"STAGE={update_stage}\n", f"STAGE={stage2}\n")
            (bench / "apps/fixture_git/fixture_git/hooks.py").write_text("# server edits")
            log.write_text("")
            result = subprocess.run(["bash"], input=command, text=True, capture_output=True, env=env)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn("-m pip", log.read_text())
            self.assertEqual((bench / "apps/fixture_git/fixture_git/hooks.py").read_text(), "# server edits")


if __name__ == "__main__":
    unittest.main()
