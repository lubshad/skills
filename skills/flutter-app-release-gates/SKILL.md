---
name: flutter-app-release-gates
description: Use when implementing Flutter Utils update/maintenance gates or setting up a new Flutter Utils mobile release pipeline.
---

# Flutter Release Gates

Reuse Flutter Utils policy, not a second backend. New mobile deployment setup includes startup/resume gates, tests, and operator setup. Uploading a build does not authorize live policy changes or forcing an unpublished version.

**Read [the release-gate contract](RELEASE-GATES.md) before implementation or operator configuration.** It owns exact query/model fields, identifiers, sheet behavior, lifecycle concurrency, link handling, and the test matrix.

## Invariants

- Public shared-client `get_app_config` sends installed release version and exact logical app identifier; gate Android/iOS only, never infer iOS from “not Android.”
- Apply flags only when managed: maintenance → forced update → optional update → normal. Blocking sheets cover the whole navigator; optional dismissal never suppresses later blocking policy.
- Root release BLoC checks startup/every resume/retry. Queue a fresh foreground check behind an in-flight request; failed refresh preserves confirmed blocking policy, while initial failure invents none.
- Settings are advisory client policy, not API authorization. Only authorized site changes are allowed; confirm store availability before mandatory updates.

## Verification

Use the contract's model, BLoC, widget, navigation, lifecycle, and real-device/store checks. Run format, analysis, and focused tests; report mocked versus actual device/store evidence separately.
