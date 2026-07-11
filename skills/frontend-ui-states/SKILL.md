---
name: frontend-ui-states
description: Use when designing loading, empty, error, retry, no-results, or no-data behavior across frontend surfaces.
---

Follow these UI state rules for all frontend platforms.

## When Not To Apply

- Do not add a loading or retry state to fully local, synchronous presentation-only components.
- For a mutation that does not load a screen-sized dataset, use the product's inline pending and error feedback rather than a full-page state.

## Read Alongside

- Listings: `frontend-listing-screens.md`.
- Forms and mutations: `frontend-forms.md`.
- Flutter implementation: `flutter-common-widgets.md`; Next.js implementation: `nextjs-empty-states.md`.

## Required States

Every screen or component that fetches data must handle:
- Initial loading.
- Empty state.
- No-results state after search/filter.
- Error state with retry.
- Incremental/loading-more state when applicable.

## Loading

- Use the platform's shared loading component for repeated loading states.
- Listing/table initial loads should use a skeleton or structured placeholder that matches the final layout where possible.
- Avoid mixing unrelated loading styles for the same surface type.
- Do not block already visible records behind a full-screen spinner when refreshing or loading a later page.

## Empty And No-Results

- Empty-state titles should be short and factual.
- Description text should explain what belongs there or how to recover.
- No-results states should suggest clearing or adjusting filters.
- If creation is allowed, include the relevant Add/create action in true empty states.

## Error And Retry

- Show human-readable errors, not raw exception strings.
- Include a clear retry action when the failed operation can be retried.
- Preserve existing data when a refresh or later page fails.
- Use product-styled dialogs/panels/toasts, not native browser alerts.

## Platform Adapters

- Flutter shared widget rules live in `flutter-common-widgets.md`.
- Next.js empty-state component usage lives in `nextjs-empty-states.md`.

## Verification

- Verify each applicable state can be reached without stale data disappearing during refresh or retry.
- Verify retry repeats the failed operation with the current query or form state.
- Verify errors are understandable without exposing raw server or exception details.
