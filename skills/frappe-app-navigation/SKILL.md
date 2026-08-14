---
name: frappe-app-navigation
description: Use when creating or editing Frappe desktop icons, workspace sidebars, app navigation, or desk entry points.
---

Follow these rules when giving a new Frappe app its entry point on the desk — a single Desktop Icon that opens a Workspace Sidebar listing the app's key documents.

Read `frontend-admin-panels.md` first for admin/back-office navigation intent and operator workflow expectations. This file owns only Frappe Desk Desktop Icon and Workspace Sidebar implementation details.

## When To Apply

- A new app that user-facing staff will open from `/app`.
- Any time you are adding the first navigational surface to a CoreAxis Solutions app.
- Updating the sidebar of an existing app to surface newly added DocTypes, Reports, or Pages.

## Core Rule

- **Always declarative, never code.** Use Frappe's auto-synced directories. No `after_install` hooks, no fixtures, no patches.
- **One Desktop Icon per app**, whose `link_type` is `Workspace Sidebar` and whose `sidebar` points to the app's Workspace Sidebar. This turns the icon on `/app` into a click target that opens the sidebar.
- **Only surface required docs.** The sidebar is for frequently used documents, not every DocType in the app. Start minimal (often just `<App> Settings`) and add items as real workflows emerge. Do not dump the full module tree in.

## File Layout

```
apps/<app>/<app>/
├── desktop_icon/
│   └── <app>.json              # one file per icon
└── workspace_sidebar/
    └── <app>.json              # one file per sidebar
```

Both directories live at the inner module-package root (`apps/<app>/<app>/`) — the same level as `hooks.py` and `modules.txt`. Frappe auto-discovers them on `bench install-app` and `bench migrate`.

## Desktop Icon — required fields

```json
{
  "doctype": "Desktop Icon",
  "name": "<App Title>",
  "label": "<App Title>",
  "app": "<app_name>",
  "link_type": "Workspace Sidebar",
  "link_to": "<App Title>",
  "sidebar": "<App Title>",
  "icon_type": "Link",
  "bg_color": "blue",
  "standard": 1,
  "owner": "Administrator",
  "modified_by": "Administrator",
  "creation": "<YYYY-MM-DD HH:MM:SS.000000>",
  "modified": "<YYYY-MM-DD HH:MM:SS.000000>"
}
```

- `link_to` and `sidebar` must equal the Workspace Sidebar `name`.
- `standard: 1` is mandatory — otherwise Frappe's orphan cleanup deletes it on migrate.
- `app` must match the Python app slug in `modules.txt`/`hooks.py`.

## Workspace Sidebar — required fields

```json
{
  "doctype": "Workspace Sidebar",
  "name": "<App Title>",
  "title": "<App Title>",
  "module": "<Module Name from modules.txt>",
  "app": "<app_name>",
  "header_icon": "<lucide-icon-name>",
  "standard": 1,
  "items": [ /* see below */ ],
  "owner": "Administrator",
  "modified_by": "Administrator",
  "creation": "<YYYY-MM-DD HH:MM:SS.000000>",
  "modified": "<YYYY-MM-DD HH:MM:SS.000000>"
}
```

## Icons

Frappe uses **Lucide icons** exclusively. Icon names are kebab-case strings (e.g., `"calendar-days"`, `"lock-keyhole"`).

- Browse valid names at https://lucide.dev/icons/ — names are exact and case-sensitive; an unknown name renders nothing silently
- `header_icon` on the sidebar root — pick the broadest concept for the app
- Every Link item and Section Break **must** have a non-empty, meaningful `icon`, including child items (`"child": 1`).
- Do not reuse the same icon for different items in the same sidebar unless they represent the same destination.
- After any icon change, bump `"modified"` so `bench migrate` picks it up

**Common icon mappings:**

| Concept | Icon |
|---------|------|
| Settings / configuration | `settings` |
| User / person | `user` |
| Users / group | `users` |
| Employee | `square-user-round` |
| Dashboard / overview | `layout-dashboard` |
| Home | `home` |
| Sport / game | `trophy` |
| Position / role (sport) | `shield` |
| Template / checklist | `clipboard-list` |
| Education / learning | `book-open` |
| Certification | `award` |
| Match / event date | `calendar-days` |
| Career / job | `briefcase` |
| Achievement / medal | `medal` |
| Media / image gallery | `image` |
| Review / comment | `message-square` |
| Report / document | `file-spreadsheet` |
| Permissions / lock | `lock-keyhole` |
| Audit / secure log | `file-lock` |
| Setup / database | `database` |
| Organization | `organization` |
| Payments / finance | `credit-card` |
| Email | `mail` |
| Integration / API | `plug` |
| Automation | `zap` |
| Print | `printer` |
| Website | `globe` |
| Map / location | `map` |
| Health / medical | `heart-pulse` |
| Notification / alert | `bell` |
| Calendar | `calendar` |
| Chart / analytics | `bar-chart-2` |

When no exact match exists, prefer a concrete noun icon over a generic one.

## Sidebar Item Types

Each entry in `items[]` is one line in the sidebar. Keep fields to only what the type needs.

**Link item** (DocType, Report, Page, or URL):

```json
{
  "type": "Link",
  "label": "Vimeo Settings",
  "link_type": "DocType",        // DocType | Report | Page | URL
  "link_to": "Vimeo Settings",   // exact name; for URL use the `url` key instead
  "icon": "settings",            // lucide icon
  "indent": 0,
  "collapsible": 1
}
```

**Section break** (visual grouping only, no destination):

```json
{
  "child": 0,
  "collapsible": 1,
  "type": "Section Break",
  "label": "Reports",
  "icon": "file-spreadsheet",
  "indent": 1,
  "keep_closed": 1,
  "link_type": "DocType",
  "show_arrow": 0
}
```

- **Do not invert `indent`.** Native Frappe Desk uses `indent: 1` on the collapsible Section Break header. Its nested Link children use `child: 1` with `indent: 0`; `child: 1` is what renders the child indentation.
- Nested Link items should use the native shape:

```json
{
   "child": 1,
   "collapsible": 1,
   "icon": "file-spreadsheet",
   "indent": 0,
  "keep_closed": 0,
  "label": "Fixed Asset Register",
  "link_to": "Fixed Asset Register",
  "link_type": "Report",
  "show_arrow": 0,
  "type": "Link"
}
```

- Child icons are required. Use a meaningful, distinct Lucide icon for each child link; do not omit it for the compact native ERPNext Desk appearance.
- For external URL items, set `link_type: "URL"` and add `"url": "/dashboard/..."`.

## Collapsible Sidebar Groups

Use a Section Break followed immediately by its child links. Keep `keep_closed: 1` on the Section Break when the group should start collapsed. Do not place unrelated items between a Section Break and its children, or Frappe cannot render the group predictably.

Native reference: `apps/erpnext/erpnext/workspace_sidebar/assets.json` uses this exact structure for its Maintenance and Reports groups.

## Rules for Choosing Sidebar Items

- **Required docs only.** A good rule of thumb: an item belongs here if a normal operator will open it at least weekly. Admin-only infrequent settings still belong (one item), but back-office child DocTypes do not.
- **Settings first.** The app's Single Settings DocType is almost always the first item.
- **No duplicates.** Don't re-link the same DocType from multiple sections.
- **No dead links.** Every `link_to` must resolve to an existing DocType/Report/Page at install time. Verify with `Glob apps/<any>/<any>/**/doctype/<slug>/<slug>.json`.
- **Group with Section Breaks** only when you have 3+ items in the group — otherwise leave them flat.

## Registration

- No entry is needed in `hooks.py`. Frappe's `sync_for()` discovers both directories automatically.
- `modules.txt` must already contain the module name used in the Workspace Sidebar's `module` field.

## Post-Edit Migration — Mandatory

**Any edit to a `desktop_icon/*.json` or `workspace_sidebar/*.json` file MUST be followed by `bench migrate` in the same turn.** Frappe only picks up the declarative JSON on migrate — without it the desk still shows the pre-edit state and the user cannot verify the change.

This applies to:
- Creating a new icon or sidebar file
- Adding, removing, or reordering sidebar items
- Changing labels, icons, colors, or `link_to` targets
- Any edit that bumped `modified` (if you didn't bump `modified`, fix that first — the sync step is a no-op otherwise)

Steps:

1. **Look up the site.** Do not ask the user which site unless the app-to-site mapping is genuinely unknown. Check `project-connections.md` first - it maps each Frappe app on this bench to its primary site (e.g. `exam` -> `mcal.localhost`, `masar` -> `masar.localhost`).
2. **Run migrate for that site:**

   ```bash
   bench --site <site> migrate
   ```

3. **Confirm the tail of the log has no `Traceback` / `Error`.** The `Removing orphan Workspace Sidebars` / `Removing orphan Desktop Icons` lines are normal — records with `standard: 1` are preserved.
4. **Tell the user to hard-refresh `/app`** and confirm:
   - The icon appears with the correct label and color.
   - Clicking it opens the sidebar (not a DocType list).
   - Every sidebar item navigates to the intended destination.

If the icon or sidebar fails to appear after migrate, the usual cause is `standard: 0` (orphan-cleaned), a stale `modified` timestamp, or a `name` mismatch between the icon's `sidebar`/`link_to` and the sidebar's `name`.

## Reference Example

- `apps/frappe_vimeo/frappe_vimeo/desktop_icon/frappe_vimeo.json`
- `apps/frappe_vimeo/frappe_vimeo/workspace_sidebar/frappe_vimeo.json`

These mirror the pattern used by `apps/buzz/buzz/desktop_icon/buzz.json` + `apps/buzz/buzz/workspace_sidebar/buzz.json`, scoped down to a single "Vimeo Settings" item for v1.

## Verification

- Run `bench --site <site> migrate` and confirm it completes without a traceback.
- Hard-refresh `/app` and verify the icon, sidebar, labels, and destinations.
- Verify a rerun preserves standard records and does not create duplicate navigation documents.
