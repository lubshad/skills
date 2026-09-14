---
name: skill-updates
description: Use when a task is not clearly covered by an existing skill, or when creating, updating, or reviewing skills in this workspace's .agents/skills catalog.
---

# Skill Updates

This skill is a decision gate for keeping the workspace skill catalog complete. The rules and skill index live in `.agents/AGENTS.md`, and indexed skills live at `.agents/skills/<name>/SKILL.md`. It triggers whenever the current task is not covered by an existing skill and governs how skills are created or updated.

## When This Skill Activates

Run this check on every task before writing code or making changes:

1. Scan the available skills (the skill table in `.agents/AGENTS.md` and the system-provided skill list).
2. If at least one skill's "When to apply" clearly matches the task's domain or workflow, the task is covered — proceed normally, do not prompt.
3. If no skill clearly covers the task, the task is uncovered — stop and run the Confirmation Flow below.

Do not prompt when:

- The request is purely informational or conversational (no task is being performed).
- The user explicitly says to skip skill creation (for example "just fix it", "don't make a skill").
- The user explicitly asks to create or update a skill — the intent is already confirmed, so go straight to execution.

The user has opted in to prompting on every uncovered task, including one-off fixes. Do not silently skip the prompt because the task seems small.

## Confirmation Flow

When the task is uncovered, use the `question` tool to ask the user how to proceed. Offer these options:

- **Create a new skill** — capture a reusable skill for this domain/workflow.
- **Update an existing skill** — extend a skill that is close but incomplete. Name the closest candidate in the question text.
- **Skip — continue without a skill** — do the task now; no catalog change.

If the answer is ambiguous, ask one focused follow-up (for example, which existing skill to update, or the preferred name for a new skill). Do not ask more than one round of clarification unless the user invites it.

On confirmation, execute the chosen path below.

## Creating a New Skill

1. **Pick the name** following these rules (enforced by `.agents/scripts/validate_skills.py`):
   - Lowercase, hyphenated, matches `^[a-z0-9]+(?:-[a-z0-9]+)*$`.
   - The directory name must equal the `name` frontmatter field.
   - Prefer a known prefix when the domain fits: `admin-`, `api-`, `app-`, `coreaxis-`, `country-`, `event-`, `flutter-`, `frappe-`, `frontend-`, `github-`, `login-`, `nextjs-`, `pipecat-`, `project-`, `setup-`.
   - Non-prefixed names (like `skill-updates`) are acceptable for cross-cutting meta skills.
   - Confirm the name with the user before writing if it is not obvious from the confirmation.

2. **Create** `.agents/skills/<name>/SKILL.md` with this structure:
   - YAML frontmatter with `name` and `description`.
   - `description` must start with the literal words **Use when**.
   - An H1 title.
   - A "When to Use" / core-rules section.
   - A `## Verification` section (over 100 lines without one triggers a quality warning; add it regardless for consistency).

3. **Keep platform specifics out of shared skills.** Shared `frontend-*` skills must not contain `lib/core/` or other platform-specific paths (quality warning). Put platform examples in a `references/` subfolder or in the platform adapter skill. See `frontend-button-clicks` for the `references/` pattern.

4. **Do not reference skill names that do not exist.** A backtick reference of the form <code>`name.md`</code> whose name starts with a known prefix is validated; a dangling reference fails the catalog check. Only backtick-reference skills that already exist in `.agents/skills/`.

## Updating an Existing Skill

1. Read the current `SKILL.md` before editing.
2. Edit in place. Keep the `name` field unchanged — it must match the directory name.
3. Keep `description` starting with "Use when".
4. If the change is really a new routing scenario rather than new skill content, add an entry to `.agents/skills/routing-scenarios.json` instead of bloating the skill body.
5. Do not introduce dangling backtick `.md` references.

## Registering the Skill

A new or renamed skill is not active until it is indexed:

1. Add a row to the correct table in `.agents/AGENTS.md`:
   - Platform-Agnostic Frontend UI, Flutter Implementation, Next.js Implementation, Backend And Frappe, Cross-Platform Technical, Workspace Workflow, or Compatibility Adapters.
   - Format: <code>| `name.md` | one-line "When to apply" description |</code>
   - The `validate_skills.py` index check fails if any skill directory is absent from `.agents/AGENTS.md`.
2. If the skill defines a multi-skill routing scenario, add an entry to `.agents/skills/routing-scenarios.json` with `scenario` and `skills` fields. The scenario validator fails if any listed skill is not an active skill directory.

## Validation

After every create/update/rename, run both validators. They must exit 0 with no errors before the work is considered done:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 .agents/scripts/validate_skills.py
PYTHONDONTWRITEBYTECODE=1 python3 .agents/scripts/validate_skill_scenarios.py
```

Quality warnings (long skills without a Verification section, platform specifics in shared skills, heavy absolute language) do not block, but fix them when practical.

## Verification

- `SKILL.md` frontmatter has `name` (matches directory) and `description` starting with "Use when".
- No backtick `.md` references to skills that do not exist in `.agents/skills/`.
- New or renamed skill is listed in the matching `.agents/AGENTS.md` table.
- New routing scenarios in `routing-scenarios.json` reference only active skill directories.
- Both validation scripts exit 0.
