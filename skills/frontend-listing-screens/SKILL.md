---
name: frontend-listing-screens
description: Use when designing listing, table, index, search, filter, pagination, refresh, row action, or bulk-selection UX.
---

Follow these listing-screen rules strictly for every frontend platform.

## When Not To Apply

- Do not apply full listing-screen controls to small static option lists, read-only summaries, or a short embedded related-record section.
- Apply the relevant parts only when the surface loads remote or mutable records; do not add search, filtering, selection, or deletion without a product need.

## Read Alongside

- Required: `frontend-ui-states.md`.
- Admin surfaces: `frontend-admin-panels.md`.
- Platform implementation: `flutter-listing-screens.md` or `nextjs-listing-screens.md`.
- Metadata-driven listings: `frontend-dynamic-listing-fields.md`.
- Frappe-backed live data: `frappe-listing-realtime.md`.

## Data And Fetching

- Fetch only the fields needed for list rows/cards. Load full details on the detail screen or modal.
- Search and filtering must be server-side or API-backed; do not fetch an unbounded dataset and filter it only on the client.
- Do not fetch or render unbounded record sets by default. Use pagination, Load more, infinite scroll, or scoped lazy loading.
- Reset pagination to the first page when search, filters, sort, or category tabs change.
- Search inputs should update results incrementally on character input using a short debounce (e.g., ~300ms), with Enter/submit still available to force immediate search.
- In metadata-driven listing filters (including inline text filters), run the filter/search callback on each character change via debounced `onChanged` so users do not need to press Enter for each key stroke.

## Required Features

Every listing screen must include:
- Pagination or the platform-approved equivalent.
- Search.
- Filtering with multiple filter fields where the data supports it.
- Refresh or retry.
- Empty, loading, error, and no-results states from `frontend-ui-states.md`.
- A primary View/details action when records have a detail surface. Offer Delete only when the user has permission and the record lifecycle supports deletion; do not add other row actions unless the task requires them.

## Desktop / Admin Tables

- Use a dense table/listing surface for desktop admin screens.
- Top controls: search and filters on the left; refresh and Add/create on the right when available.
- Toolbar controls in the top control row must have full control-height tap targets, not icon-only or text-fragment-only activation areas (e.g., sort field/button pills should respond to taps across the full visible control height).
- Table headers stay visible while rows scroll.
- If columns overflow, scroll horizontally inside the table region only.
- Include a checkbox column, Select All, local multi-row selection state, and a compact selected-count action segment when the listing has a meaningful supported batch action.
- Bulk action state stays local to the listing screen unless the product explicitly requires cross-screen selection.
- When multi-row deletion is supported, expose it in the selected-count segment and confirm with the selected record count before sending the destructive request. Do not leave selected actions as placeholders.
- Use shared table-header, pagination, loading, empty, and error widgets where the platform has them.
- Avoid row dividers unless explicitly requested; use subtle alternating near-white row shading, selected/hover states, and alignment.

## Admin Details Navigation

- Admin listing rows/cards must have a primary click/tap action that opens a dedicated read-only details page in the current platform navigator/router context, unless the listing has a stronger domain-specific primary action.
- Pass only the record ID or minimal typed route arguments to the details page; the destination fetches its own data.
- Keep list APIs limited to row/card fields. Load detail data on demand through the platform's normal state/data layer.
- Include loading, error with retry, and empty/missing-field states in the details page. Use plain fallback values such as `Not set`, `No email`, or the platform's established copy.
- Preserve table interactions: checkbox selection must not trigger detail navigation, View/Delete row action buttons stay independent, and destructive actions still follow `frontend-interaction-patterns.md`.
- On mobile, navigate to the details screen through the platform's normal navigator/router pattern.

## Pagination

- Default page size: **20**.
- Page-size selector options are global and must be exactly: **10, 20, 50, 100**.
- Do not override page-size options per listing screen unless the task explicitly requires it and the reason is documented.
- Persist the user's "per page" preference in local storage before/when reloading page 1.
- Load the saved page size before the first data fetch.
- Shared pagination widgets must stay generic: they receive current values and emit callbacks; the feature/store/repository owns persistence.

## Mobile

- Prefer infinite scroll or Load more instead of page-number pagination.
- Do not show page-size selectors on narrow mobile screens.
- Use list tiles or compact cards instead of full data tables.
- Use pull-to-refresh where the platform supports it.

## Shared Loading Placeholders

- Use the platform's shared listing-loading placeholder to keep shimmer/loading layouts consistent across admin listings.
- Keep shared placeholders structure-first (selection/action rails and content bars) and avoid additional one-off outer insets or spacing not present in the actual row surface.
- Build per-listing loading layouts to match visible columns and table density, and prefer shared row patterns instead of custom placeholder rows.

## Platform Adapters

- Flutter implementation details live in `flutter-listing-screens.md`.
- Next.js implementation details live in `nextjs-listing-screens.md`.
- Frappe-backed listings that must update from server-pushed create, update, delete, workflow, or background-job changes must also read `frappe-listing-realtime.md` after the platform adapter.

## Verification

- Verify initial loading, empty, no-results, error/retry, refresh, and loading-more states.
- Verify search/filter/sort reset pagination and retain the intended state after refresh.
- Verify row selection and actions do not trigger detail navigation accidentally.
- Verify the desktop table and the narrow-screen fallback at their supported breakpoints.
