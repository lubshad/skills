---
name: frontend-admin-panels
description: Use when designing admin/back-office layouts, operator workflows, density, actions, or recovery.
---

# Admin Panels

**Task surfaces, not marketing pages.** Optimize repeated scanning, comparison, filtering, approval, editing, and recovery.

Desktop-first shells use stable side navigation, compact top bar, dense aligned tables, filters/status chips and meaningful batch actions. Narrow fallbacks preserve hierarchy. Shared top bars contain only title/session context unless a page owns more. Desktop collapse/expand stays in sidebar utilities immediately before logout; narrow top menus only open hidden navigation.

Listings fill shell height without unnecessary body padding. Keep controls/headers/pagination outside row scrolling. One aligned toolbar: left search/filters/compact selected-count actions; right Refresh/Add (primary when allowed). Dense consistent headers/shading/alignment/overflow and compact desktop page-size/navigation/count footers follow `frontend-listing-screens.md`.

Confirm destructive/high-impact actions with record context before requests. Preserve input where practical, give clear errors/retry, and avoid silent failures. Desk serves internal administration; user products belong in Flutter/Next.js.

## Verification

Check desktop density, narrow fallback, reachable controls/footer, sidebar/header ownership, meaningful selection/actions, and recoverable failures.
