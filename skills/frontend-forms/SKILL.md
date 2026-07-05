---
name: frontend-forms
description: Use when designing or reviewing form UX, validation, field behavior, selection components, save states, or dummy-data linkage.
---

Common form rules that apply to all frontend platforms. Platform-specific form skills add implementation syntax on top.

## Scope

Apply to every create/edit form, onboarding flow, profile form, filter form with persisted state, and reusable form component set.

## Layout And Structure

- Group related fields into logical sections.
- Keep submit actions easy to reach and visible without unnecessary scrolling.
- On mobile, complex form surfaces should use fullscreen flows or sheets with sticky header and sticky bottom actions.
- On desktop/tablet-wide layouts, use structured 2-3 column layouts where space permits and readability is preserved.
- Use platform/product standard modal and dialog patterns; do not create feature-specific modal styling for ordinary forms.

## Selection Components

- Do not use simple dropdowns for network-bound items, dynamic/searchable lists, or option sets with more than 5 items.
- Use the platform's searchable selector, picker screen, or dialog pattern instead.
- Selection components must preserve typed search/filter state while results load.
- In searchable/link dialogs, search should be debounced at a per-character cadence (for example 300ms) to avoid immediate network calls on each key event while still updating promptly.
- Show current link selection in the result list itself (for example through selected/highlighted row styling), not as a separate selected-value panel outside the list.
- For searchable/select dialog link fields, support keyboard operation:
  - Opening with `Space` or `Enter` when focused.
  - Navigating option results with `ArrowUp`/`ArrowDown`.
  - Selecting with `Enter` should select the currently highlighted result when one exists.
- When keyboard navigation moves the highlighted result outside the visible list viewport, automatically scroll the list just enough to keep that result visible.
- Link search must include canonical identifiers and titles where the target schema supports them: always search `name`, and include `title` and `id` when those fields exist or are already requested by the selector API.
- In searchable link dialogs, if Enter is pressed while no row is highlighted, run search as a fallback.
- Keep the selector interaction patterns platform-native (dialog/picker), not custom inline hacks, including keyboard focus flow.

## Validation

- Validate required fields on the client before submission.
- Show inline error messages near the affected input, not only in a toast or page-level banner.
- Prevent duplicate submissions while a request is in progress.
- Show validation errors on blur or on submit, whichever comes first.
- Apply format validation for structured fields:
  - Email: reject values that do not match `user@domain.tld`.
  - Phone: validate expected digit length/format for the selected country code.
  - URL: require `http://` or `https://` and a valid domain.
  - Numeric fields: reject non-numeric input and enforce min/max bounds where applicable.
  - Date fields: reject future dates for birth dates and past dates for expiry dates.

## Keyboard / Input Type Mapping

Configure inputs so the device shows the most appropriate keyboard. Platform files provide exact syntax.

| Field type | Keyboard hint |
|-----------|--------------|
| Email | Email keyboard |
| Phone / OTP | Telephone / numeric keyboard |
| Decimal numeric | Decimal keyboard |
| Integer numeric | Numeric keyboard |
| URL | URL keyboard |
| Multiline text | Multiline / return key |
| Search | Search keyboard |
| Password | Obscured text |

Set autocomplete/autofill hints where supported.

## State After Save

- After a successful create or update, immediately update the parent list or detail view.
- Do not require manual refresh or a navigation round-trip to see saved changes.

## Random Data Filling

- Follow `frontend-dummy-data.md`.
- Every non-trivial form should provide a dev-only autofill button.
- Autofill values must come from the single shared platform generator and write into the same controlled state as manual input.
