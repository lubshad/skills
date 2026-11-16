---
name: flutter-listing-screens
description: Use when implementing Flutter listings, tables, search/filter, pagination, refresh, selection, or row actions.
---

# Flutter Listings

Read `frontend-listing-screens.md` first. Use widget → BLoC → repository → client. List calls fetch row fields; separate detail BLoC concerns fetch full records on demand.

## Queries and persistence

Represent search/filter/sort/pagination/refresh as events with shared first-page-reset rules. Debounce text `onChanged` about 300ms with immediate submit; `onSubmitted` alone is insufficient, including inline/dynamic text filters.

For schema-driven Frappe listings, fetch applied runtime meta (`frappe.desk.form.load.getdoctype`), not raw `/api/resource/DocType`, when custom fields/property setters affect UI. Persist meta; use cache immediately, refresh in background, and update rows/cache on changes. Manual refresh can force fresh meta first.

Load page-size preferences before initial fetch and save through the shared preferences helper before/when reloading page 1. Repository/shared defaults match the UX skill. Generic pagination emits `onPageSizeChanged`; feature code owns keys/persistence.

## Widgets and bulk actions

Reuse core toolbar/header/pagination/selection/state widgets. `AdminListingLoadingPlaceholder.columns` matches visible density. Shared widgets contain no feature models/BLoCs/repositories/API calls; features own rows, filters, callbacks, and local selection.

Bulk delete: local IDs → count confirmation → BLoC bulk-delete event → clear selection after confirmation → repository reload. Frappe repository calls `/api/method/frappe.desk.reportview.delete_items` with `doctype` and JSON-encoded `items`; no per-record loops or `Future.wait`.

Toolbar custom controls may sit before Refresh/Add. All visible controls, including split sort/menu anchors, need full-height hit areas.

## Dynamic filters

Popover draft rows stay local until Apply/Clear dispatches the existing filter event, resetting pagination once. Choices come from applied value metadata plus system fields; operators follow field type/Frappe Desk. Use the shared searchable picker backed by local metadata (label/name/type), not a static dropdown. Changing field resets operator/value.

Encode `{value, operator}`; preserve `=`, `!=`, `like`, `not like`, `in`, `not in`, `is`, comparisons, `Between`, and `Timespan`. Linked values use async selectors; Select/Check use local options; generic text/number/date may use compact inputs without specialized controls.

Cell filters use the same event with raw `{value, operator: '='}`; repeating the active field/value removes that filter while preserving other filters/search/sort. Normalize checks to backend raw values. The first subject column remains detail navigation. Attach gestures only to rendered secondary value text/chips, not full cells; whitespace keeps row navigation. Exclude selection/action/detail controls and show `Filter by <Field>` affordance only for real filterable items.

## Devices

Desktop keeps toolbar/header/pagination outside vertical rows; horizontal overflow stays inside table/header/body. Reuse checkbox/select-all widgets. Row bodies navigate through named routes in the current `BuildContext`/active nested section navigator; checkbox/actions consume their own taps.

Mobile uses tiles/cards, pull-to-refresh, infinite scroll/Load more, and hides desktop pagination controls.

## Verification

Check event resets, cache/forced-meta refresh, persisted size before first fetch, native bulk RPC, popover draft/apply behavior, raw cell toggles, independent selection/actions, and nested detail routing.
