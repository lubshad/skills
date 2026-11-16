---
name: frappe-app-navigation
description: Use when creating or editing Frappe Desktop Icons, Workspace Sidebars, or Desk entry points.
---

# Frappe App Navigation

Read `frontend-admin-panels.md` first. **Declarative only:** one Desktop Icon opens one Workspace Sidebar; no install hooks, fixtures, or patches. Put `<app>.json` in inner-package `apps/<app>/<app>/desktop_icon/` and `workspace_sidebar/`, beside `hooks.py`/`modules.txt`. `sync_for()` auto-discovers them on install/migrate.

## Document shape

Each file is one JSON object with `standard: 1`, correct app slug, Administrator owner/modified_by, and full `creation`/`modified` timestamps (`YYYY-MM-DD HH:MM:SS.000000`). Bump modified on every edit; stale timestamps skip sync and nonstandard records are orphan-cleaned.

Desktop Icon needs doctype/name/label/app, `link_type: "Workspace Sidebar"`, `link_to` and `sidebar` matching sidebar name, `icon_type: "Link"`, and `bg_color` (example blue). Sidebar needs doctype/name/title/module/app, broad `header_icon`, and items; module must exist in `modules.txt`. No hooks registration.

## Items and icons

Expose frequent operator workflows, not the whole module tree or child DocTypes. Settings Single usually comes first; infrequent admin settings can remain one item. No duplicate targets/dead links; verify DocType/Report/Page definitions exist. Group only 3+ related items.

Link shape: `type: "Link"`, label, exact `link_type` (DocType/Report/Page/URL), `link_to`, meaningful icon, `indent: 0`, `collapsible: 1`; URL links use `url` instead of destination name.

Section Break shape: `child: 0`, `collapsible: 1`, `type: "Section Break"`, label/icon, `indent: 1`, `keep_closed: 1` for initially collapsed, `link_type: "DocType"`, `show_arrow: 0`. Follow immediately with children: `child: 1`, `indent: 0`, `collapsible: 1`, `keep_closed: 0`, `show_arrow: 0`, Link fields. Child flag—not inverted indent—provides native indentation. No unrelated entries between header/children.

Use exact case-sensitive kebab-case Lucide names from https://lucide.dev/icons/; unknown icons render blank. Every Link/Section Break, including children, needs a meaningful icon; reuse only for the same destination. Prefer concrete nouns when no exact match exists.

References: ERPNext `workspace_sidebar/assets.json` groups; `apps/frappe_vimeo/frappe_vimeo/{desktop_icon,workspace_sidebar}/frappe_vimeo.json` and Buzz equivalent entrypoints.

## Verification: migrate in the same turn

Any navigation JSON edit requires `bench --site <site> migrate` **in the same turn**. Resolve app/site through `project-connections.md`; ask only if genuinely unknown. Verify no traceback/error (orphan-removal messages are normal for standard records). Ask for hard-refresh of `/app`; check label/color, icon opens sidebar rather than list, destinations resolve, and rerun preserves records without duplicates. Missing entries usually mean nonstandard flags, stale modified, or mismatched names.
