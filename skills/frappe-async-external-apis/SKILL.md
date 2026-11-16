---
name: frappe-async-external-apis
description: Use when Frappe calls external APIs, webhooks, payment/storage providers, or long-running services.
---

# Frappe External Work

**Persist intent, then enqueue.** Requests validate, save local state/pending status, and return without waiting for remote or long-running work unless synchronous behavior is explicitly required. Document safety-critical requirements for verified remote results; local-only database work does not activate this skill.

Read `frappe-python.md`; external-client endpoints also need `frappe-api-contracts.md`, mounted refreshes `frappe-realtime-updates.md`.

## Execution

Use `frappe.enqueue(..., enqueue_after_commit=True)` or the dedicated job helper. Make retries idempotent; track queued/syncing/complete/failed. Log unexpected failures through `frappe.log_error()` without secrets and retain recoverable document status.

Create locally pending first where possible; save local updates before sync; prefer background external deletion. Long external processing uses polling/scheduled synchronization to terminal status. Offer manual retry when useful; UI need not wait where pending suffices.

## Verification

Check intent/status persist before job eligibility, retries avoid duplicate remote effects, failures expose diagnostic/recoverable local state, and clients receive realtime or a supported refresh at completion.
