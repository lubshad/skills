---
name: nextjs-listing-screens
description: Use when implementing Next.js listing, index, table, pagination, search, filter, refresh, row action, or bulk-selection pages.
---

Follow these Next.js implementation rules for listing pages in `next_apps/masarnext/`. Read `frontend-listing-screens.md` first; it owns listing UX behavior.

## When To Apply

- Any public or authenticated listing/index page.
- Any component or API route that fetches, filters, searches, sorts, or renders a collection.
- Any conversion from static/sample listing data to live backend data.

## Pagination Pattern

- MasarNext public listing pages use a visible Load more button unless the task explicitly requests page-number pagination.
- Fetch the first page only for initial render.
- Use explicit API pagination parameters such as `limit`/`offset` or `page`/`page_size`.
- Responses must include enough metadata for the UI to know whether more records are available, such as `has_more`, `next_offset`, or `total_count`.
- Keep filter, search, and sort parameters stable across Load more requests.
- Reset to the first page when filters, search, sort, or category tabs change.

## Rendering And Fetch Boundaries

- Do not block SSR on listing data that is not required for first paint; follow `nextjs-page-performance.md`.
- Disable the Load more button while the next page is loading and avoid duplicate requests.
- Append newly loaded records; do not replace the first page.
- Preserve existing filters/search state and scroll position while loading more records.
- If a later page fails, keep already loaded records visible and provide a retry path.
- For admin details navigation from `frontend-listing-screens.md`, navigate from the row/card client interaction and fetch detail data only when the details route needs it.
- Detail navigation must use the app's established route segment or search-param pattern.

## Backend/API Expectations

- Listing endpoints must never return all records by default.
- Apply conservative default and maximum page sizes server-side.
- Return only fields needed by list cards/table rows.
- If counts are expensive, return `has_more` by requesting one extra record instead of forcing total count.
- Dedicated details endpoints may return fuller record data, but list endpoints should not grow to support detail fields unless those fields are visible in the row/card.

## Verification

- Initial load requests only the first page.
- Load more appends without duplicating records.
- The button disables during loading and disappears when there are no more records.
- Changing search/filter/sort clears old results and starts from page one.
- Admin details navigation from `frontend-listing-screens.md` works without replacing the admin shell.
