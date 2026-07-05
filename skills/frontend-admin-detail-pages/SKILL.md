---
name: frontend-admin-detail-pages
description: Use when designing admin detail, profile, edit, tabbed form, right overview rail, save, reset, loading, error, or saving-state pages.
---

Follow these admin detail-page rules for profile/detail/edit screens in admin and back-office surfaces.

## Scope

Use this for any admin detail page that opens a full record from a listing, route, or profile link. This file owns product/UI behavior. Platform adapters own implementation syntax, state classes, routing, component paths, and API calls.

## Data And Page Role

- Detail pages fetch the full record by stable ID through the platform's normal state/data layer.
- The detail page is the editable task surface for a record.
- Listing row/card taps should navigate directly to the detail page; do not add a listing overview sidebar as an intermediate step.
- Do not pass full row objects from listings into detail pages except as temporary route hints; the detail page must load current record data.
- If the detail form depends on metadata/schema as well as record data, start metadata/schema loading in parallel with the record load at the detail page level. Do not wait until the loaded record mounts the form widget before starting schema loading.
- Right overview rails should reuse the same loaded detail state as the editable form. Do not perform a second fetch of the same record just to populate the overview rail.

## Header

- Show the record display name as the primary title.
- Show the stable record ID, status, or compact metadata as the subtitle or adjacent metadata. Prefer record ID as the default subtitle when available.
- Do not show the shared/main admin top appbar on nested detail, create, edit, profile, or form pages. The shared appbar with user/session details belongs only to first-level navigation destination screens such as listing, dashboard, or index screens rendered directly from the right-side navigation area.
- Use a compact local detail header or action row when needed for Back, Save, Reset, Edit, contextual workflow actions, or Refresh. This local header must not include global user details, global search, notification actions, or other shared appbar content.
- Disable Save/Reset while saving or while no editable data is loaded.
- Header actions must trigger the same controlled form state as manual field edits.
- Keep the header compact and task-focused; do not add global search, marketing copy, or unrelated dashboard controls.

## Layout

- Make the editable detail form the primary content surface.
- On desktop, a right-side read-only overview rail may be shown within the detail page when it helps operators keep record context visible.
- The overview rail is secondary. It must not duplicate all editable fields or compete with the form as the main task surface.
- On tablet and mobile, collapse to a single-column/full-width detail flow. Do not force a cramped side rail.
- Avoid nested cards and heavy page chrome. Use section spacing, subtle borders, and constrained content widths for scanability.
- Use a white root/background surface for detail pages so form shells and shimmer placeholders remain high-contrast and visually consistent.

## Form Tabs

- Use tapped category tabs for dense admin detail forms.
- Tabs should be domain sections such as `Overview`, `Company Details`, `Personal Details`, `Salary`, `Contact`, `Permissions`, or other record-specific categories.
- Each tab owns one coherent domain of fields. Do not mix identity, company, salary, and contact fields in one long generic page.
- Prefer fixed/tap-selected tabs where practical. Do not rely on horizontal swipe/drag as the only way to move between form sections.
- The active tab should preserve unsaved draft values when switching tabs.
- Keep Save/Reset outside the tab body when using a shared page-level form draft.

## Form Actions

- Prefer header actions over sticky bottom bars on desktop admin detail pages.
- Use sticky bottom actions only when the platform pattern or mobile layout needs persistent reachability.
- Prevent duplicate submissions while saving.
- After a successful save, update the detail view immediately without requiring navigation away or manual refresh.
- For create/update success, show an explicit in-screen success toast or status feedback before returning to the listing; avoid duplicate success notifications from both detail and listing flows.
- On save failure, keep the user's draft visible and show a product-styled error with recovery.

## States

- Provide initial loading, error with retry, saving, save error, and missing-field fallbacks.
- Loading placeholders should preserve the intended detail layout where practical, including any desktop overview rail.
- For dynamic metadata-backed forms, distinguish the loading phases:
  - Initial record loading may show the full detail shimmer, including the desktop overview rail if the final detail page has one.
  - Form metadata/schema loading should show only the form-area shimmer when the record is already available, because the overview rail can read from the existing detail state.
- On detail pages with tabbed forms and a right overview rail, use a single reusable shimmer scaffold that mirrors the final layout:
  - Left: 2-row structure (top tab row shimmer, then repeating form field section shimmers).
  - Right (desktop only): overview rail shimmer.
  - Ensure the shimmer container spans the same visual height as the final detail layout.
- Use plain missing-value copy such as `Not set`, `No email`, or the platform's established fallback.
- Preserve already loaded data when a refresh or save attempt fails.

## Platform Adapters

- For Flutter implementation, read `flutter-forms.md`, `flutter-state-management.md`, `flutter-routing.md`, `flutter-common-widgets.md`, and `flutter-linting.md` as needed.
- For Next.js implementation, read `nextjs-forms.md`, `nextjs-page-performance.md`, `nextjs-responsive-scaling.md`, and routing/data-fetching guidance as needed.
