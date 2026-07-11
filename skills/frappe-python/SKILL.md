---
name: frappe-python
description: Use when writing or reviewing Python code in Frappe apps, including whitelisted methods, database access, files, and errors.
---

Follow these Python rules strictly when working on Frappe apps.

## When Not To Apply

- Do not use this skill for Frappe configuration-only JSON, fixtures, or frontend code; use the matching customization or frontend skill.
- Read `frappe-async-external-apis.md` before adding any remote call or long-running work.

## Read Alongside

- External-client APIs: `frappe-api-contracts.md`.
- Files and images: `frappe-file-images.md`.
- Realtime client refreshes: `frappe-realtime-updates.md`.
- Outbound work: `frappe-async-external-apis.md`.

## Type Safety

- **Always use type hints** on function parameters and return types.
- Use `str | None` syntax (Python 3.10+), not `Optional[str]`.
- Import types from `typing` only when needed (`Any`, `TypedDict`).

## Frappe Conventions

### Whitelisted Methods
- Decorate public API methods with `@frappe.whitelist()`.
- Use `allow_guest=True` only for endpoints that genuinely need unauthenticated access.
- Validate inputs early — use `frappe.throw()` for user-facing errors.
- Enforce document and operation permissions explicitly; never rely on a client-supplied user, role, document name, or company scope.
- Keep writes idempotent when clients may retry after a timeout, especially for create, payment, workflow, or external-sync flows.

### Database
- Use `frappe.get_doc`, `frappe.get_all`, `frappe.db.get_value` — never write raw SQL unless absolutely necessary.
- Let Frappe manage the request transaction for ordinary whitelisted-method writes. Call `frappe.db.commit()` only at an intentional transaction boundary, such as a patch, a controlled batch, or code that must persist before subsequent independent work.
- Check column existence with `frappe.db.has_column()` before accessing custom fields.
- Batch related lookups and use `in` filters instead of per-record queries that create N+1 database access.
- If a backend write must refresh a mounted listing in Flutter, Next.js, or Frappe Desk, read `frappe-listing-realtime.md` and prefer ORM writes that trigger `Document.notify_update()`.

### File Handling
- Use `frappe.get_doc({"doctype": "File", ...})` to create file attachments.
- Set `is_private: 0` for public files, `is_private: 1` for private.
- Always attach files to a specific doctype and document.

### Error Handling
- Use `frappe.throw(_("message"))` for user-facing errors (translatable).
- Use `frappe.log_error()` for logging unexpected exceptions.
- Never silently swallow exceptions.
- Do not include passwords, tokens, private file paths, or full third-party responses in user-facing errors or logs.

## Code Style

- Use **tabs** for indentation (Frappe convention).
- Keep functions focused — extract helpers for reusable logic.
- Prefix internal helper functions with `_` (e.g., `_get_authenticated_user`).
- Use f-strings for string formatting.

## Verification

- Run the focused test or create one for each changed whitelisted method, including permission-denied and invalid-input paths.
- Verify writes roll back together when validation fails before the request completes.
- Verify list and child-record access use bounded, batched queries.
- Verify external work is enqueued after commit and reports a durable local status.
