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

### Desk-Managed Application Settings

- Configure application features, business rules, provider credentials, and rollout switches through permission-controlled Settings DocTypes in Frappe Desk. Reuse the app's existing Settings DocType where suitable.
- Treat Desk settings as the source of truth. Do not add duplicate or hidden application gates in `site_config.json`, `common_site_config.json`, or `frappe.conf`.
- Store provider secrets in Password fields and enforce server-side permissions for settings changes. Keep secrets out of client responses and logs.
- Keep infrastructure settings required by Frappe, such as database and Redis connections and encryption keys, in their supported site/Bench configuration. This rule does not move infrastructure secrets into Desk or authorize deleting existing configuration.

### Whitelisted Methods
- Decorate public API methods with `@frappe.whitelist()`.
- Use `allow_guest=True` only for endpoints that genuinely need unauthenticated access.
- Validate inputs early — use `frappe.throw()` for user-facing errors.
- Enforce document and operation permissions explicitly; never rely on a client-supplied user, role, document name, or company scope.
- Keep writes idempotent when clients may retry after a timeout, especially for create, payment, workflow, or external-sync flows.

### Database

- For watcher test provisioning use `.automation/database-access.md`: `PR_WATCH_DB_ADMIN_USER` / `PR_WATCH_DB_ADMIN_PASSWORD` are trusted-helper-only settings loaded from private env, not site connection overrides. Preallocate scoped test databases/users, bootstrap with `setup_db=False`, and run app/tests without admin settings. Never put root credentials in shared/site configuration, arguments, prompts or logs. Keep guarded ownership-based disposal and durable evidence; same-UID private files are not a hostile-code security boundary.
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

### Choose the smallest safe test environment

- **Default: a temporary site in the existing Bench**, using local MariaDB and a dedicated disposable database/user, when site creation is authorized. Follow `.automation/local-bench-testing.md` for watcher jobs. Use existing scoped approval rather than asking again for the same operation; watcher approval does not extend to unrelated interactive tasks.
- Before choosing an environment, verify actual imported app/dependency paths and SHAs, relevant local modifications, installation hooks, patches and external effects. A site isolates data, not app code, the Python environment, Redis, workers or the filesystem. A worktree working directory alone does not select Frappe imports.
- **Use a separate temporary Bench only for a concrete isolation need:** different code/dependency revisions, baseline-to-head migration testing, or effects that cannot safely use the shared environment. Record that reason before proposing or requesting a new Bench. Never switch, patch or relink shared apps, install shared dependencies, or restart shared services to make tests fit. A fresh head installation is not baseline-to-head migration evidence.
- A separate Bench can still use existing local MariaDB with its own disposable database/user; a private database daemon is not the default. Use disk-backed scratch per `.automation/storage.md`. Private Redis/processes require the applicable approval when shared-service safety cannot be established.
- For authorized exclusive creation of a verified absent private Bench directory, unrelated protected processes do not establish ownership of that directory. Check the target and its parents, preserve existing/interrupted resources, and keep strict identity/process checks for resources actually involved in the run. Ambiguous ownership of an involved resource remains a blocker.
- Protect existing sites, mock outbound effects, disable scheduling/email for the new site, avoid shared-worker jobs, and record ownership/evidence privately. This guidance grants no unrelated site creation/deletion or infrastructure permission.
- Where disposal is authorized (as for the four installed watchers), automatically clean up proven-owned test site/database/user/files on success or failure, preserve logs and verify absence. Bench drop-site archives files: remove the owned archive too, never force-drop unknown resources. Record interrupted cleanup for scoped reconciliation.

### Check changed behavior

- For application-setting changes, verify that the Desk setting controls the behavior without a site-config opt-in, that disabling it blocks the feature, and that unauthorized users cannot change it.
- Run the focused test or create one for each changed whitelisted method, including permission-denied and invalid-input paths.
- Verify writes roll back together when validation fails before the request completes.
- Verify list and child-record access use bounded, batched queries.
- Verify external work is enqueued after commit and reports a durable local status.
