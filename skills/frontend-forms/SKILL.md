---
name: frontend-forms
description: Use when designing or reviewing form UX, form button styling, validation, field behavior, selection components, save states, or dummy-data linkage.
---

Common form rules that apply to all frontend platforms. Platform-specific form skills add implementation syntax on top.

## Scope

Apply to every create/edit form, onboarding flow, profile form, filter form with persisted state, and reusable form component set.

## When Not To Apply

- Do not use this skill for a one-click confirmation, a search box without persisted state, or a display-only detail page.
- A copy-only edit inside a form does not activate this skill unless field or form behavior changes.
- Apply only the relevant validation and input rules to compact inline controls.

## Companion Skills

- Visual form or button changes: read `frontend-design-consistency.md` first to preserve the surrounding UI.
- Required: `frontend-ui-states.md` for remote loading or save failures.
- Destructive or modal flows: `frontend-interaction-patterns.md`.
- Flutter implementation: `flutter-forms.md`; Next.js implementation: `nextjs-forms.md`.
- Development autofill: `frontend-dummy-data.md` only when adding or changing autofill behavior.

## Layout And Structure

- Group related fields into logical sections.
- Keep submit actions easy to reach and visible without unnecessary scrolling.
- On mobile, complex form surfaces should use fullscreen flows or sheets with sticky header and sticky bottom actions.
- On desktop/tablet-wide layouts, use structured 2-3 column layouts where space permits and readability is preserved.
- Use platform/product standard modal and dialog patterns; do not create feature-specific modal styling for ordinary forms.

## Form Button Consistency

- Match buttons to nearby inputs, selectors, tables, and toolbars in height, typography, spacing, borders, radii, and icon size. Compact buttons must belong to the existing UI, not form a separate visual style.
- Reuse shared button components, compact variants, and design tokens. If a needed variant is missing, extend the shared component or style rather than repeat feature-local overrides.
- Prefer compact secondary actions inside forms and table rows. For desktop admin forms, use 32px form buttons and 28px row actions as starting points, with 12px text, 14px icons, and tight horizontal padding. Follow established screen density and readable labels rather than forcing these sizes across all products.
- Use neutral borders for secondary actions where consistent with the app. Preserve the existing primary and destructive action hierarchy, colors, and meaning.
- Preserve clear keyboard focus, disabled and pending states, and accessible names. Use larger touch targets on touch devices; compact visual size must not reduce touch usability.
- Keep the change local to the requested form controls. Preserve unrelated layout, fields, navigation, and other UI parts; broader changes require explicit approval.
- Apply this standard when creating or updating form button presentation. It does not authorize an app-wide restyle or unrelated changes during copy-only or nonvisual work.

## Selection Components

- Show readable names/titles as the primary text for linked records in results and selected form fields, never raw internal IDs when readable text exists. Preserve the selected title and resolve titles for prefilled/saved links; keep canonical IDs in draft values and submission payloads. IDs may be secondary text for duplicate-name disambiguation. Use a safe fallback only when no permitted title is available.
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
  - URL: default to `http://` or `https://` and a valid host. Permit localhost, internal hosts, or other schemes only when the field's documented contract supports them.
  - Numeric fields: reject non-numeric input and enforce min/max bounds where applicable.
  - Date fields: reject future birth dates. Default to rejecting past expiry dates for new active credentials; allow historical expiry dates when the editing/import workflow explicitly supports them.

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
- Default to dev-only autofill for non-trivial data-entry forms. Do not add it solely for a copy-only change, or to credential, OTP, payment, or other sensitive forms without an explicit safe testing requirement.
- Autofill values must come from the single shared platform generator and write into the same controlled state as manual input.

## Verification

- Compare changed buttons within the full form against adjacent controls and a maintained comparable screen. Check labels, icons, alignment, action hierarchy, keyboard focus, and touch usability at relevant widths; report any unverified visual or interaction checks.
- Verify required and format validation, including keyboard-only submission.
- Verify a pending save prevents duplicate submission and exposes one clear success or failure outcome.
- Verify server validation errors remain attached to the affected fields where possible.
- Verify the form remains usable with the keyboard open on supported mobile widths and at desktop widths.
- Verify workflow-specific validation exceptions against the field/API contract, and report actual checks and any unverified interactions.
