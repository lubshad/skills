---
name: project-pr-watcher
description: Use when creating, configuring, or reviewing scheduled project-wide PR review, feedback, merge, and release automation.
---

# Project PR Watchers

Discover → review → feedback/merge → deploy → verify/reconcile. Read `project-connections.md` first, then [the watcher runbook](WATCHER-RUNBOOK.md) before configuring or operating a watcher. Its authorization, evidence, retry, cleanup, and continuity requirements are mandatory, not optional background reading.

## Authority and evidence

- Verify actual repository/remotes/base refs and concrete dependencies. Explicit policy owns repository allowlist, actions, deployment targets, schedule, and model. Discovery grants no authority; production is separately authorized.
- Verify OpenCode workspace session location and server-selected model before submission. Current four watchers use the runbook's authorized Terra configuration without fallback; labels/self-description are not selection attestation.
- Review exact head/base in isolated checkouts. One focused reviewer per installed watcher; confirmed major PR-introduced defects only. Optional unavailable QA is a note, not an author gate; required CI/owner gates and unfinished source review still block merging.
- Runner owns scheduling, lifecycle comments, evidence validation, feedback delivery, bounded continuations, locks, and artifact disposal. Preserve immutable history and stable findings. Never turn incomplete agent work into an author defect.
- Recheck live head/base/checks immediately before protected merge. No automatic fixes/conflict resolution or branch-protection bypass.
- Release only confirmed watcher-owned merges/durable pending work on approved targets, from independent verified clones. Persist intent/SHAs/workflows before waiting; reconcile interruption rather than repeat promotion. Failed deployments are not automatically retryable.
- Preserve user checkouts, unknown resources, secrets, and historical state. Exact ownership, isolation, disk admission, and bounded process cleanup follow the runbook/shared automation contracts.

## Verification

Use mocked runner/helper checks and `.automation/check.py` as documented. Configuration work never authorizes live reviews, retrospective comments, merges, releases, credential changes, or infrastructure provisioning. Report review completion, merge, promotion, deployment, and health as separate evidenced outcomes.
