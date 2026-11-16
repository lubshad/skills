---
name: project-manager
description: Use when analyzing live CoreAxis ERP project/task health, deadlines, dependencies, risks, briefs, or explicitly requested changes.
---

# Project Manager

Read `erp-assistant.md` first for MCP, selection, privacy, permissions, mode, and execution. Not generic application planning; loading this skill grants no ERP authority.

## Resolve first

Inspect metadata and request only necessary Project fields: name/display name/status/active/priority/progress method and percentage, expected/actual dates/hours, modified. Normal analysis prefers active Yes/non-Cancelled, but explicit inactive/cancelled requests override that filter. Match name/display name case-insensitively; unique exact matches need no confirmation.

Missing/ambiguous project uses `question`: header `Project`, “Which CoreAxis project should I use?”, single selection, up to five matches plus next/previous five. Report `<project_name> (<Project.name>)`; Task filters use canonical `Project.name`.

Paginate tasks sufficiently and match IDs/subjects, asking when ambiguous. Needed metadata may include status/priority/progress, group/milestone/parent, expected/actual dates/hours, dependencies, description/completed_on/modified. Present readable subjects with IDs where useful; avoid copying long descriptions.

## Changes

Fetch current targets/dependencies and validate fields/values, links, dates, milestone semantics, cycles, and parent-before-child order. Proposals show canonical target/current→new/risk/side effects. Proposal defaults may suggest today/High but are unsaved, not commitments. Actual creation uses specified values or verified site defaults; omitted optional deadline stays unset. Ask only for required/material ambiguity, check project-scoped duplicates, and preserve ERP mode/permission restrictions. No special execution phrase is needed for explicit write requests in Build; switching modes alone is not authorization.

## Analyze and rank

Use site timezone/today, or disclose session-date fallback once. Verify statuses: normally Open/Working/Pending Review/Overdue are incomplete and only Completed is complete. Exclude group-task double counts.

- Critical: overdue milestone, overdue Urgent/High, or overdue prerequisite of incomplete work.
- Due today; Working; Pending Review; blocked by incomplete declared dependency; no-deadline unscheduled.
- Upcoming risk: milestone/Urgent/High due within three calendar days.
- Recent completion: completed today or previous seven calendar days with completion date.

Action order: overdue milestones → overdue Urgent/High → due today → due/overdue review → blockers → upcoming milestone/high work → unscheduled. Within categories: milestone, Urgent>High>Medium>Low>unset, earliest deadline, lowest progress. Resolve prerequisites before starting blocked tasks.

Calculate available status/completion/overdue/due/blocked/unscheduled/review counts/percentages, milestone completion, average incomplete progress, expected/actual-hour variance, elapsed-time versus completion, momentum, and inferred stale Working tasks. Flag missing dates/priorities/estimates, contradictory progress/status, undated completions, and task/project timeline conflicts. Separate fact/calculation/inference/recommendation.

## Brief and verification

Use `Project Manager Brief: <name> (<ID>)`, date/timezone, then Executive Summary; Project Health; Must Address Now; Milestones, Blockers, And Review Queue; Deadline Gaps; Progress And Insights; Recommended Actions; Data Quality And Assumptions. Include project status/priority/timeline/completion/schedule/workload; ranked task subject/ID/status/priority/deadline/progress/reason; momentum/hours/trends. Note empty sections briefly and prioritize risk.

## Verification

Check MCP/mode/scope/IDs, metadata/pagination/status/date boundaries, dependencies/calculations/missing data, and fact/proposal labels. Read-only work makes no ERP changes; writes verify saved IDs/partial outcomes. This workflow changes no local application code.
