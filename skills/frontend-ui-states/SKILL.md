---
name: frontend-ui-states
description: Use when designing loading, empty, no-results, error/retry, or incremental data states.
---

# UI States

Remote-data surfaces handle initial loading, true empty, search/filter no-results, retryable error, and applicable loading-more. Fully local synchronous presentation needs no loading/retry; small mutations use inline pending/error, not full-page states.

## Keep useful content visible

Reuse shared components and consistent layout-matching skeletons for initial lists/tables. Refresh/later-page requests and failures retain loaded records instead of full-screen spinners.

Empty titles are brief/factual; descriptions explain expected content/recovery. True empty offers Add when permitted; no-results suggests adjusted/cleared filters. Errors are human-readable, secret-safe, product-styled, with retry when supported—not raw exceptions or browser alerts.

Listings use `frontend-listing-screens.md`; forms/mutations `frontend-forms.md`. Flutter widgets follow `flutter-common-widgets.md`; Next.js follows `nextjs-empty-states.md`.

## Verification

Reach each applicable state, retain data through refresh/retry failure, and ensure retry repeats the failed operation with current query/form state. No raw server/exception exposure.
