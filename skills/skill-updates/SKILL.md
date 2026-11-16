---
name: skill-updates
description: Use when a task is not clearly covered by an existing skill, or when creating, updating, or reviewing skills in this workspace's .agents/skills catalog.
---

# Skill Updates

Keep the local catalog complete and focused. `.agents/AGENTS.md` owns rules/indexing; `.agents/skills/<name>/SKILL.md` owns each skill.

## Coverage gate

Before code or changes, scan the workspace index and system-provided skills. A clear domain/workflow match means proceed without prompting.

For uncovered work, including one-off fixes, stop and use `question` to offer **Create a new skill**, **Update an existing skill** (name the closest candidate), or **Skip — continue without a skill**. An ambiguous answer gets one focused follow-up unless the user invites more.

Skip the prompt for informational/conversational requests, explicit opt-outs (including “just fix it”), or explicit skill creation/update requests. The last already authorizes the skill work.

## Write or update

Read an existing skill before editing; retain its name. For new names, use lowercase hyphens matching `^[a-z0-9]+(?:-[a-z0-9]+)*$`, equal to the directory name. Prefer a domain prefix from `.agents/scripts/validate_skills.py`; cross-cutting names may omit one. Confirm unclear names before writing.

Each skill needs YAML `name` and `description` starting **Use when**, an H1, scope/core rules, and `## Verification`.

**One rule, one home.** Keep shared product rules separate from platform implementation. Shared `frontend-*` entry points exclude platform paths such as `lib/core/`; put platform examples in `references/` or adapters (see `frontend-button-clicks`). Keep core instructions inline; disclose long examples and uncommon branches through conditional references.

State non-triggers and when each companion is required or optional. Route by changed behavior, not every surface in a touched file. Reference only existing local skills; dangling backtick `name.md` references with known prefixes fail validation.

## Register and route

New/renamed skills need a row in the matching platform, frontend, technical, workflow, or compatibility table of `.agents/AGENTS.md`: <code>| `name.md` | one-line trigger |</code>.

For multi-skill routing or new boundary cases, update `.agents/skills/routing-scenarios.json` rather than expanding skill prose. Follow `.agents/skills/routing-scenarios.md`: include `scenario`, `skills`, and applicable forbidden skills/actions and accepted/rejected selections. All referenced skills must be active. These checks test explicit routing contracts, not model understanding.

## Verification

After every create/update/rename, run all three checks; each must exit 0 without errors:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 .agents/scripts/validate_skills.py
PYTHONDONTWRITEBYTECODE=1 python3 .agents/scripts/validate_skill_scenarios.py
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s .agents/scripts -p 'test_*.py'
```

Confirm names/frontmatter, local references, index membership, and active scenario skills. Quality warnings are nonblocking; fix them when practical (over 100 lines without Verification, platform details in shared skills, excessive absolute language).
