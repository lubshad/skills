---
name: frappe-customizations
description: Use when changing Frappe DocTypes, custom fields, property setters, patches, or customization exports.
---

# Frappe Customizations

Only customize apps published by **CoreAxis Solutions**; do not directly modify core/third-party apps.

## Schema versus data

- App-owned DocType schema: edit its JSON, bump modified, migrate. No redundant patch.
- Foreign/core custom fields and data changes (seed/rename/backfill): one-concern idempotent patches under `<app>/patches/v1_0/`, with a top comment explaining why. No fixtures.
- Register every patch chronologically in `patches.txt` **and import/call it in install.py `after_install()`**, ordered by dependencies, so fresh installs match upgrades.

All JSON creation/modified values need full `YYYY-MM-DD HH:MM:SS.000000`; every edit to DocType/workspace/icon/sidebar JSON bumps modified or Frappe may silently skip it.

## New DocTypes and selection

Provide empty `__init__.py`, definition JSON, and a real `Document` subclass controller—not an empty Python file. Include generated typing where applicable (`TYPE_CHECKING`, `frappe.types.DF`, nullable fields and child parent/parentfield/parenttype).

Child JSON: `istable: 1`, `editable_grid: 1`, `sort_field: "creation"`, `permissions: []`. Multi-value selection uses only `Table` plus a dedicated child DocType containing Link fields, referenced by parent `options`. `Select` is single-value; no `Table MultiSelect` or newline Select as multi-value storage.

## Declarative documents

Use one-object JSON, not fixtures/patches: `<app>/desktop_icon/<name>.json`, `<app>/workspace_sidebar/<name>.json`, and `<app>/<module>/workspace/<name>/<name>.json`. Set `standard: 1`, correct app, and newer modified; `sync_for()` handles discovery. Prefer declarative form when no conditional logic is needed.

## API packages

Use `api/` by domain (`lookups.py`, `registration.py`, `profile.py`, etc.), not one `api.py`. Re-export every whitelist function through `api/__init__.py` to retain dotted paths. Shared private helpers live in `_utils.py`; tests import them from their actual module, not re-exports.

Use shared guest-rejecting `get_authenticated_user()` and mark intended guest/read-only lookup endpoints with `allow_guest=True`. This skill's API convention requires commits after write operations. `override_whitelisted_methods` is only for core overrides; ordinary paths resolve through exports.

## Naming series

Dedicated fixed-prefix counters use direct `"autoname": "OA-.#####"` → `OA-00001`, with `OA-` in `tabSeries`. `format:OA-.#####` leaves literal hashes; `format:OA-{#####}` may consume the global counter. Use `format:` only for braced field/date combinations such as `LOG-{YYYY}-{MM}-{fieldname}`.

Metadata changes affect future inserts only. Repair existing malformed names through an idempotent `frappe.rename_doc(..., force=True)` data patch using the intended direct series; preserve links. Bump modified and migrate after changing autoname.

## Verification

Run local `bench --site <site> migrate` for schema/navigation/patch changes before committing. Check clean-session metadata/permissions, patch rerun safety, and fresh-install parity. Naming changes need two created records, correct synced autoname/prefix counter, and link-preserving idempotent repair.
