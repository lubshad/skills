---
name: frappe-python
description: Use when writing or reviewing Python code in Frappe apps, including whitelisted methods, database access, files, and errors.
---

# Frappe Python

Apply to Python backend code, not configuration-only JSON, fixtures, or frontend code.

## Read by branch

- Before adding remote calls or long-running work: `frappe-async-external-apis.md`.
- External-client APIs: `frappe-api-contracts.md`.
- Files/images: `frappe-file-images.md`.
- Realtime refresh: `frappe-realtime-updates.md`. For mounted listings, also read `frappe-listing-realtime.md`; prefer ORM writes that trigger `Document.notify_update()`.
- Before choosing/provisioning a test environment: [test isolation](references/test-isolation.md), including watcher database rules.

## Code

Type every parameter and return value. Use Python 3.10+ unions (`str | None`), importing `typing` types only as needed. Use tabs, f-strings, focused functions, and `_`-prefixed internal helpers; extract reusable logic.

## Settings: Desk owns application behavior

Use permission-controlled Settings DocTypes for features, business rules, provider credentials, and rollout switches; reuse existing settings where suitable. Desk is the source of truth: no duplicate/hidden application gates in `site_config.json`, `common_site_config.json`, or `frappe.conf`.

Store provider secrets in Password fields; enforce settings permissions server-side and exclude secrets from responses/logs. Infrastructure settings (database, Redis, encryption keys) stay in supported site/Bench configuration. This grants no permission to delete existing configuration.

## APIs and errors

Whitelist public methods with `@frappe.whitelist()`; allow guests only for genuinely unauthenticated endpoints. Validate early and enforce document/operation permissions server-side, independent of client-supplied identity, role, document, or company scope.

Make retryable writes idempotent, especially creates, payments, workflows, and external syncs: a timeout must not duplicate an operation.

Use translated `frappe.throw(_("message"))` for user errors and `frappe.log_error()` for unexpected exceptions; surface failures rather than silently swallowing them. Exclude passwords, tokens, private paths, and full third-party responses from errors/logs.

## Data and files

- Use `frappe.get_doc`, `frappe.get_all`, and `frappe.db.get_value`; raw SQL only when necessary.
- Let Frappe manage ordinary request transactions. Commit only at deliberate boundaries: patches, controlled batches, or persistence before independent work.
- Check custom columns with `frappe.db.has_column()` before access. Batch lookups with `in` filters to avoid N+1 queries.
- Create attachments through `frappe.get_doc({"doctype": "File", ...})`, linked to a specific DocType/document. Set `is_private` to `0` for public files, `1` for private.

## Verification

- Settings: Desk controls behavior without site-config opt-in; disabling blocks it; unauthorized users cannot change it.
- Each changed whitelisted method: run/create a focused test covering permissions and invalid input.
- Confirm rollback on validation failure and bounded, batched list/child queries.
- Confirm external work enqueues after commit and exposes durable local status.
