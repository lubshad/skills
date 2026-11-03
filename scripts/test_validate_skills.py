"""CLI regression tests using disposable skill catalogs."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


VALIDATOR = Path(__file__).with_name("validate_skills.py")


class SkillValidatorTests(unittest.TestCase):
	def setUp(self):
		self.directory = tempfile.TemporaryDirectory()
		self.addCleanup(self.directory.cleanup)
		self.root = Path(self.directory.name)
		(self.root / "scripts").mkdir()
		shutil.copyfile(VALIDATOR, self.root / "scripts" / VALIDATOR.name)
		skill = self.root / "skills" / "example"
		skill.mkdir(parents=True)
		(skill / "SKILL.md").write_text(
			"---\nname: example\ndescription: Use when testing a catalog.\n---\n# Example\n",
			encoding="utf-8",
		)
		self.index = self.root / "AGENTS.md"
		self.index.write_text("| `example.md` | Example skill |\n", encoding="utf-8")

	def run_validator(self):
		return subprocess.run(
			[sys.executable, str(self.root / "scripts" / VALIDATOR.name)],
			capture_output=True, text=True, timeout=10,
		)

	def test_missing_index_entry_fails(self):
		self.index.write_text("# Empty index\n", encoding="utf-8")
		result = self.run_validator()
		self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
		self.assertIn("active skill is absent from the index: example.md", result.stderr)
		self.assertNotIn("Skill catalog valid:", result.stdout)

	def test_stale_index_entry_fails(self):
		with self.index.open("a", encoding="utf-8") as index:
			index.write("| `removed-skill.md` | Removed skill |\n")
		result = self.run_validator()
		self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
		self.assertIn("index references unknown skill: removed-skill.md", result.stderr)
		self.assertNotIn("Skill catalog valid:", result.stdout)

	def test_skill_count_excludes_loose_files(self):
		(self.root / "skills" / "routing-scenarios.md").write_text("# Routes\n", encoding="utf-8")
		(self.root / "skills" / "routing-scenarios.json").write_text("[]\n", encoding="utf-8")
		result = self.run_validator()
		self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
		self.assertEqual(result.stdout, "Skill catalog valid: 1 skill directories checked.\n")
		self.assertEqual(result.stderr, "")

	def test_missing_index_file_fails(self):
		self.index.unlink()
		result = self.run_validator()
		self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
		self.assertIn("cannot verify skill index because the file is missing", result.stderr)

	def test_invalid_skill_fails(self):
		(self.root / "skills" / "example" / "SKILL.md").write_text("# No frontmatter\n", encoding="utf-8")
		result = self.run_validator()
		self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
		self.assertIn("missing YAML frontmatter", result.stderr)

	def test_quality_warnings_remain_nonblocking(self):
		with (self.root / "skills" / "example" / "SKILL.md").open("a", encoding="utf-8") as skill:
			skill.write("Reference text.\n" * 101)
		result = self.run_validator()
		self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
		self.assertIn("Skill catalog quality warnings:", result.stdout)
		self.assertIn("without a Verification section", result.stdout)
		self.assertEqual(result.stderr, "")


if __name__ == "__main__":
	unittest.main()
