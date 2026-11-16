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

	def test_disclosed_runbook_links_resolve_from_their_own_directory(self):
		skill = self.root / "skills" / "example"
		with (skill / "SKILL.md").open("a", encoding="utf-8") as entry:
			entry.write("Read [details](references/details.md#rules).\n")
		(skill / "references").mkdir()
		(skill / "references" / "details.md").write_text(
			"# Rules\nReturn to [entry](../SKILL.md).\n"
			"Read [remote](https://example.com/missing.md) or [this section](#rules).\n",
			encoding="utf-8",
		)
		result = self.run_validator()
		self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

	def test_missing_link_in_disclosed_runbook_fails(self):
		skill = self.root / "skills" / "example"
		(skill / "DETAILS.md").write_text(
			"Read [missing](references/missing.md#rules).\n", encoding="utf-8",
		)
		result = self.run_validator()
		self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
		self.assertIn("missing Markdown reference references/missing.md#rules", result.stderr)

	def test_unknown_skill_in_disclosed_runbook_fails(self):
		(self.root / "skills" / "example" / "DETAILS.md").write_text(
			"Read `frontend-missing.md`.\n", encoding="utf-8",
		)
		result = self.run_validator()
		self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
		self.assertIn("references unknown skill frontend-missing.md", result.stderr)

	def test_runbook_absolute_language_warning_is_not_hidden_by_disclosure(self):
		(self.root / "skills" / "example" / "DETAILS.md").write_text(
			"Always verify ownership.\n" * 11, encoding="utf-8",
		)
		result = self.run_validator()
		self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
		self.assertIn("DETAILS.md: uses absolute language on 11 lines", result.stdout)


if __name__ == "__main__":
	unittest.main()
