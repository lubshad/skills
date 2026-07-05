---
name: frappe-python
description: Use when writing or reviewing Python code in Frappe apps, including whitelisted methods, database access, files, and errors.
---

Follow these Python rules strictly when working on Frappe apps.

## Type Safety

- **Always use type hints** on function parameters and return types.
- Use `str | None` syntax (Python 3.10+), not `Optional[str]`.
- Import types from `typing` only when needed (`Any`, `TypedDict`).

## Frappe Conventions

### Whitelisted Methods
- Decorate public API methods with `@frappe.whitelist()`.
- Use `allow_guest=True` only for endpoints that genuinely need unauthenticated access.
- Validate inputs early — use `frappe.throw()` for user-facing errors.

### Database
- Use `frappe.get_doc`, `frappe.get_all`, `frappe.db.get_value` — never write raw SQL unless absolutely necessary.
- Always call `frappe.db.commit()` after writes in whitelisted methods.
- Check column existence with `frappe.db.has_column()` before accessing custom fields.
- If a backend write must refresh a mounted listing in Flutter, Next.js, or Frappe Desk, read `frappe-listing-realtime.md` and prefer ORM writes that trigger `Document.notify_update()`.

### File Handling
- Use `frappe.get_doc({"doctype": "File", ...})` to create file attachments.
- Set `is_private: 0` for public files, `is_private: 1` for private.
- Always attach files to a specific doctype and document.

### Error Handling
- Use `frappe.throw(_("message"))` for user-facing errors (translatable).
- Use `frappe.log_error()` for logging unexpected exceptions.
- Never silently swallow exceptions.

## Code Style

- Use **tabs** for indentation (Frappe convention).
- Keep functions focused — extract helpers for reusable logic.
- Prefix internal helper functions with `_` (e.g., `_get_authenticated_user`).
- Use f-strings for string formatting.
