---
name: coreaxis-task-workflow
description: Use when implementing a multi-step CoreAxis workspace task that needs tracked execution, verification, or explicit handoff between platforms.
---

# CoreAxis Task Workflow

Use a short, current task list for work with three or more distinct implementation or verification steps.

- Mark exactly one task as in progress while work remains.
- Update task status after each verified milestone rather than batching updates at the end.
- Keep platform work in its natural order: shared contract or backend changes before dependent client changes.
- Verify each changed surface with its relevant formatter, linter, test, build, or migration command before marking the task complete.
- Do not create task tracking for a single trivial edit or an informational request.
