---
name: frontend-listing-screens
description: Use when designing listings, tables, collection search/filter, pagination, refresh, row actions, or bulk selection.
---

# Listings

Not a mandate for full controls on static options, summaries, or short embedded related records. Apply only relevant remote/mutable behavior; no unsupported search/filter/delete/selection.

Read `frontend-ui-states.md`; admin adds `frontend-admin-panels.md`; use Flutter/Next.js listing adapter, metadata companion when generated, and `frappe-listing-realtime.md` after adapter for server-pushed changes.

## Bound data and query state

Fetch only row/card fields; details load on demand. Backend/API handles search/filter, with bounded pagination/Load more/infinite/scoped lazy loads, never unbounded client filtering. Query/filter/sort/category changes reset first page. Search/metadata-inline text reacts through per-character debounced `onChanged` (~300ms); Enter/submit forces immediate search.

Listings need pagination/equivalent, search, multiple filters where supported, refresh/retry, initial/incremental loading, empty/no-results/error states, and primary View where details exist. Delete requires permission/lifecycle support; other row actions require task scope.

## Desktop admin

Dense table fills shell. Left search/filters; right Refresh/Add (primary when allowed); full-height hit areas across toolbar controls. Header stays visible during vertical rows; horizontal overflow stays inside table only. Reuse shared headers/pagination/states; prefer near-white alternating shading/hover/selection/alignment, not row dividers unless requested.

Meaningful supported batch actions enable checkbox/select-all/local selection and compact selected-count actions beside search/filters. No global selection unless product requires it. Supported multi-delete lives there, confirms selected count before request, and actually works—not placeholders.

## Details

Primary row/card action opens dedicated read-only details in current router/navigator unless stronger domain action exists. Pass ID/minimal typed arguments; destination loads through normal data layer and handles load/error/retry/missing values. Mobile uses normal navigation. Checkbox/actions consume independent taps; destructive actions follow `frontend-interaction-patterns.md`.

## Pagination and devices

Default size **20**, global choices exactly **10,20,50,100**; exceptions need explicit task/reason. Load persisted preference before first fetch and save before/when reloading first page. Generic pagination accepts values/callbacks; feature/store/repository persists.

Mobile uses tiles/compact cards, pull-to-refresh where supported, infinite/Load more rather than page numbers, and no page-size selector. Shared skeletons mirror real row selection/action/content regions and density, without extra outer padding or feature-local placeholder reinvention.

## Verification

Exercise applicable load/empty/no-results/error/retry/refresh/load-more states; query reset/refresh retention; independent row navigation/selection/actions; and desktop/narrow layouts at supported breakpoints.
