#!/usr/bin/env python3
"""Validate the workspace's agent-skill catalog.

Run with: python3 .agents/scripts/validate_skills.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


SKILL_NAME = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SKILL_REFERENCE = re.compile(r"`([a-z][a-z0-9-]*)\.md`")
SKILL_PREFIXES = (
	"admin-",
	"api-",
	"app-",
	"coreaxis-",
	"country-",
	"event-",
	"flutter-",
	"frappe-",
	"frontend-",
	"github-",
	"login-",
	"nextjs-",
	"pipecat-",
	"project-",
	"setup-",
)
QUALITY_LENGTH_THRESHOLD = 100
ABSOLUTE_WORD = re.compile(r"\b(?:always|never)\b", re.IGNORECASE)


def parse_frontmatter(path: Path) -> tuple[dict[str, str], list[str]]:
	lines = path.read_text(encoding="utf-8").splitlines()
	if not lines or lines[0] != "---":
		return {}, [f"{path}: missing YAML frontmatter"]

	try:
		end = lines.index("---", 1)
	except ValueError:
		return {}, [f"{path}: frontmatter is not closed"]

	fields: dict[str, str] = {}
	for line in lines[1:end]:
		if not line or line.lstrip().startswith("#"):
			continue
		if ":" not in line:
			return {}, [f"{path}: invalid frontmatter line: {line!r}"]
		key, value = line.split(":", 1)
		fields[key.strip()] = value.strip().strip('"').strip("'")
	return fields, []


def validate(skills_dir: Path) -> list[str]:
	errors: list[str] = []
	names: dict[str, Path] = {}
	skill_files: list[Path] = []

	if not skills_dir.is_dir():
		return [f"Skills directory does not exist: {skills_dir}"]

	for skill_dir in sorted(skills_dir.iterdir()):
		if not skill_dir.is_dir():
			continue
		skill_file = skill_dir / "SKILL.md"
		if not skill_file.is_file():
			errors.append(f"{skill_dir}: missing SKILL.md")
			continue

		skill_files.append(skill_file)
		fields, parse_errors = parse_frontmatter(skill_file)
		errors.extend(parse_errors)
		if parse_errors:
			continue

		name = fields.get("name", "")
		description = fields.get("description", "")
		if not name:
			errors.append(f"{skill_file}: missing required frontmatter field 'name'")
		elif not SKILL_NAME.fullmatch(name):
			errors.append(f"{skill_file}: invalid skill name {name!r}")
		elif name != skill_dir.name:
			errors.append(
				f"{skill_file}: name {name!r} must match directory {skill_dir.name!r}"
			)
		elif name in names:
			errors.append(f"{skill_file}: duplicate skill name also used by {names[name]}")
		else:
			names[name] = skill_file

		if not description:
			errors.append(f"{skill_file}: missing required frontmatter field 'description'")
		elif not description.lower().startswith("use when"):
			errors.append(f"{skill_file}: description must start with 'Use when'")

	for skill_file in skill_files:
		for reference in SKILL_REFERENCE.findall(skill_file.read_text(encoding="utf-8")):
			if reference.startswith(SKILL_PREFIXES) and reference not in names:
				errors.append(f"{skill_file}: references unknown skill {reference}.md")

	return errors


def quality_warnings(skills_dir: Path) -> list[str]:
	warnings: list[str] = []
	for skill_file in sorted(skills_dir.glob("*/SKILL.md")):
		content = skill_file.read_text(encoding="utf-8")
		line_count = len(content.splitlines())
		if line_count > QUALITY_LENGTH_THRESHOLD and "## Verification" not in content:
			warnings.append(
				f"{skill_file}: {line_count} lines without a Verification section"
			)
		if (
			skill_file.parent.name.startswith("frontend-")
			and skill_file.parent.name != "frontend-dummy-data"
			and "lib/core/" in content
		):
			warnings.append(
				f"{skill_file}: shared frontend skill contains platform-specific implementation details"
			)
		absolute_lines = sum(bool(ABSOLUTE_WORD.search(line)) for line in content.splitlines())
		if absolute_lines > 10:
			warnings.append(
				f"{skill_file}: uses absolute language on {absolute_lines} lines; review for conditional defaults"
			)
	return warnings


def validate_agent_index(skills_dir: Path) -> list[str]:
	agents_file = skills_dir.parent / "AGENTS.md"
	if not agents_file.is_file():
		return [f"{agents_file}: cannot verify skill index because the file is missing"]

	listed = set(SKILL_REFERENCE.findall(agents_file.read_text(encoding="utf-8")))
	missing = sorted(
		skill_dir.name
		for skill_dir in skills_dir.iterdir()
		if skill_dir.is_dir() and skill_dir.name not in listed
	)
	return [f"{agents_file}: active skill is absent from the index: {name}.md" for name in missing]


def main() -> int:
	skills_dir = Path(__file__).resolve().parents[1] / "skills"
	errors = validate(skills_dir)
	warnings = quality_warnings(skills_dir) + validate_agent_index(skills_dir)
	if errors:
		print("Skill catalog validation failed:", file=sys.stderr)
		for error in errors:
			print(f"- {error}", file=sys.stderr)
		return 1

	print(f"Skill catalog valid: {len(list(skills_dir.iterdir()))} skill directories checked.")
	if warnings:
		print("Skill catalog quality warnings:")
		for warning in warnings:
			print(f"- {warning}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
