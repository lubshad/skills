---
name: frappe-customizations
description: Use when changing Frappe DocType customizations, fixtures, patches, custom fields, property setters, or customization exports.
---

Follow these customization rules strictly when working on Frappe apps.

## Scope

- **Only customize apps where `app_publisher` is "CoreAxis Solutions".** Do not modify third-party or core Frappe apps directly.

## App-Owned Doctype JSON (No Patch Needed)

For doctypes **defined inside the app** (files at `<app>/<app>/doctype/<name>/<name>.json`), schema changes (adding fields, reordering, changing labels) are done by **editing the JSON directly**:

1. Edit the doctype's `.json` file.
2. Bump `"modified"` to the current datetime (`"YYYY-MM-DD HH:MM:SS.000000"`).
3. Run `bench migrate` — Frappe syncs the schema automatically.

**No patch is needed.** Patches for app-owned doctypes are redundant because `bench migrate` already reads the JSON.

### Creating a New Doctype

Every new doctype directory requires **four files**:

```
<app>/<app>/doctype/<snake_name>/
├── __init__.py          # empty
├── <snake_name>.json    # doctype definition
├── <snake_name>.py      # Document subclass (required — empty file causes migration failure)
```

The `.py` controller must contain a proper `Document` subclass or Frappe will fail to import it during `bench migrate`. Minimum content:

```python
from __future__ import annotations

from frappe.model.document import Document


class MyDoctype(Document):
	# begin: auto-generated types
	from typing import TYPE_CHECKING
	if TYPE_CHECKING:
		from frappe.types import DF
		my_field: DF.Link | None
		# child table fields
		parent: DF.Data
		parentfield: DF.Data
		parenttype: DF.Data
	# end: auto-generated types
	pass
```

For **child table (istable) doctypes**, also set in the JSON:
- `"istable": 1`
- `"editable_grid": 1`
- `"sort_field": "creation"` (not `"modified"`)
- `"permissions": []` (no permissions on child tables)

Patches are only needed for:
- **Custom fields on foreign/core doctypes** (e.g. `User`, `Role`) that have no app-owned JSON.
- **Data migrations** — seeding records, renaming existing docs, backfilling values on existing rows.

## Patches (for foreign doctypes and data migrations)

- Use **patches** for custom fields on foreign doctypes and for data migrations. Never for app-owned doctype schema changes.
- Each patch is a Python function that runs once during `bench migrate`.
- Keep patches idempotent — safe to run multiple times without side effects.

## Hooks

- Add customizations to the **`after_install`** hook to ensure a clean fresh installation includes all custom fields and settings.
- Register patches in the app's `patches.txt` in chronological order.
- **Every patch added to `patches.txt` must also be imported and called in the app's `install.py` `after_install()` function.** This ensures fresh installs get the same state as migrated sites. Order calls by dependency (e.g., a field that `insert_after` another field must run after the patch that creates that field).

## Patch Structure

```
apps/<app>/
└── <app>/
    └── patches/
        └── v1_0/
            └── add_custom_field_xyz.py
```

## API Structure

- Organize whitelisted API endpoints as a **Python package** (`api/`), not a single `api.py` file.
- Structure:

```
apps/<app>/
└── <app>/
    └── api/
        ├── __init__.py        # Re-export all @whitelist functions
        ├── _utils.py          # Shared private helpers (auth, profile builders, etc.)
        ├── lookups.py         # Read-only lookup endpoints (countries, genders, sports)
        ├── registration.py    # Registration/onboarding flow
        ├── profile.py         # User profile get/update
        └── <feature>.py       # One file per feature domain
```

- **`__init__.py` must re-export every `@frappe.whitelist()` function** so that existing dotted paths (e.g. `masar.api.get_roles`) continue to work without changing `hooks.py`, Flutter, or Next.js code.
- **Shared helpers** go in `_utils.py` (prefixed with underscore = private, not whitelisted).
- **One file per domain** — group related endpoints together (e.g., all match history CRUD in `match_history.py`).
- **Auth pattern**: Use a shared `get_authenticated_user()` helper that raises on guest access, rather than repeating auth checks in every endpoint.
- **Guest endpoints**: Mark lookup/read-only endpoints with `@frappe.whitelist(allow_guest=True)`.
- **Always `frappe.db.commit()`** after write operations (`insert`, `save`, `delete_doc`) in whitelisted methods.
- **Register API paths in `hooks.py`** under `override_whitelisted_methods` only if overriding core methods; standard paths resolve automatically via the package re-exports.
- **Tests**: Import private helpers directly from their module (e.g., `from masar.api.registration import _build_registration_status`), not from `__init__.py`.

## Declarative App-Level Documents (Preferred over Patches)

Frappe auto-syncs certain app-level document types from dedicated directories during `bench migrate` and `bench install-app`. **Always use these directories instead of patches or `hooks.py` fixtures** for the following:

| Document Type | Directory | Format |
|---------------|-----------|--------|
| Desktop Icon | `<app>/desktop_icon/<name>.json` | Single JSON object per file |
| Workspace Sidebar | `<app>/workspace_sidebar/<name>.json` | Single JSON object per file |
| Workspace | `<app>/<module>/workspace/<name>/<name>.json` | Standard module path, auto-synced |

- Each file is a single JSON object (not an array) representing one document.
- Set `"standard": 1` and `"app": "<app_name>"` so Frappe's orphan cleanup doesn't delete them.
- No `hooks.py` fixtures entry is needed — Frappe discovers these directories automatically via `sync_for()`.
- When a document can be fully described by a JSON file and doesn't need conditional/programmatic logic, always go declarative.
- **Always bump `"modified"` to the current datetime whenever you edit any of these JSON files.** Frappe compares the file's `modified` timestamp to the database row; if it is not newer, the file is silently skipped during `bench migrate`. Format: `"YYYY-MM-DD HH:MM:SS.000000"`.

## Multi-Select Fields

**Always use `Table` (child table) for any field that allows selecting multiple values. Never use `Table MultiSelect` or a `Select` field with newline-separated options for multi-selection.**

- `Select` is for single-value choices only (e.g., status, category, result).
- `Table` with a dedicated child doctype is the only approved pattern for multi-select in Frappe.

### Creating a Table multi-select

1. Create a child doctype (see "Creating a New Doctype" above, with `"istable": 1`).
2. Add a `Link` field (e.g., `role → Role`, `language → Language`) to the child doctype.
3. Add a `Table` field to the parent doctype, with `"options"` set to the child doctype name.

**Example** — roles on `Coaching Specialization`:
```json
{
  "fieldname": "roles",
  "fieldtype": "Table",
  "label": "Roles",
  "options": "Specialization Role"
}
```
Child doctype `Specialization Role` has a single `Link → Role` field.

## Rules

- **App-owned doctype JSON → edit + bump `modified`, no patch.** `bench migrate` handles schema sync.
- **Foreign doctype custom fields → patch.** No app-owned JSON exists for these.
- **Data migrations → patch.** JSON edits only change schema, not existing data.
- **One concern per patch.** A patch that adds a custom field should not also change permissions.
- **Never use fixtures** (`fixtures` in `hooks.py`) for customizations — they are fragile and cause merge conflicts.
- **Always use app-level directories** (`desktop_icon/`, `workspace_sidebar/`) for standard app documents — they are declarative, self-documenting, and auto-synced by Frappe.
- **Always include the time component in `"creation"` and `"modified"` timestamps** in every doctype JSON. Use the full format `"YYYY-MM-DD HH:MM:SS.000000"` — never just `"YYYY-MM-DD"`. Frappe stores and compares full datetimes; a date-only value can cause silent failures or comparison errors.
- **Bump `"modified"` whenever you edit any JSON file** (`doctype/`, `desktop_icon/`, `workspace_sidebar/`, `workspace/`). Frappe silently skips files whose timestamp is not newer than the database row.
- **Multi-select → always `Table` with a child doctype.** Never use `Table MultiSelect` or `Select` for multi-value fields.
- **Test patches locally** by running `bench migrate` before committing.
- **Document the "why"** in a comment at the top of each patch file.

## Verification

- Run `bench --site <site> migrate` after schema, navigation, or patch changes.
- Verify the changed DocType metadata and permissions in a clean Desk session.
- Verify each new patch is idempotent and safely skips work already applied.
