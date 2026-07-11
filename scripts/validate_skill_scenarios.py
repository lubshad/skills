#!/usr/bin/env python3
"""Validate that documented skill-routing scenarios reference active skills.

Run with: python3 .agents/scripts/validate_skill_scenarios.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
	root = Path(__file__).resolve().parents[1]
	skills_dir = root / "skills"
	scenarios_path = skills_dir / "routing-scenarios.json"
	active_skills = {path.parent.name for path in skills_dir.glob("*/SKILL.md")}

	try:
		scenarios = json.loads(scenarios_path.read_text(encoding="utf-8"))
	except (OSError, json.JSONDecodeError) as error:
		print(f"Unable to read {scenarios_path}: {error}", file=sys.stderr)
		return 1

	errors: list[str] = []
	if not isinstance(scenarios, list):
		errors.append("Scenario catalog must be a JSON array")

	for index, scenario in enumerate(scenarios if isinstance(scenarios, list) else []):
		if not isinstance(scenario, dict):
			errors.append(f"Scenario {index + 1} must be an object")
			continue
		name = scenario.get("scenario")
		skills = scenario.get("skills")
		if not isinstance(name, str) or not name.strip():
			errors.append(f"Scenario {index + 1} needs a non-empty scenario name")
		if not isinstance(skills, list) or not skills:
			errors.append(f"Scenario {index + 1} needs at least one skill")
			continue
		for skill in skills:
			if skill not in active_skills:
				errors.append(f"Scenario {index + 1} references inactive skill {skill!r}")

	if errors:
		print("Skill scenario validation failed:", file=sys.stderr)
		for error in errors:
			print(f"- {error}", file=sys.stderr)
		return 1

	print(f"Skill scenarios valid: {len(scenarios)} scenarios checked.")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
