---
name: frappe-list-filters
description: Use when adding, removing, ordering, or customizing native Frappe Desk list view filters.
---

Use this skill for any Frappe Desk list screen that adds, removes, or customizes filters in list views.

Read `frontend-admin-panels.md` first for admin/back-office UX expectations. This file owns only the Frappe Desk filter implementation details.

## Goal

Keep list filters in the native Frappe list filter area and in a predictable order.

## Placement Rules

- Always place custom list filters inside Frappe's standard filter container: `.standard-filter-section`.
- Never place list filters in the page toolbar via `page.add_field()` without a target wrapper.
- Never place custom list filters ahead of the built-in identity filters.

## Required Order

Use this order on list screens:

1. `ID`
2. Main title/name field
3. Custom business filters such as `Sport`, `Role`, `Status`, or similar

If multiple custom filters are added, keep them after `ID` and the main title/name field.

## Implementation Pattern

- Wait until the list view has initialized its filter area.
- Use `listview.page.page_form.find(".standard-filter-section")` as the insertion target.
- Append custom filter wrappers to that section so built-in `ID` and title/name filters stay first.
- If the custom controls are helper filters that drive a derived `name in [...]` filter, exclude them from Frappe's normal standard-filter serialization.

## Do

- Use the native list filter row so placement matches other Frappe lists.
- Keep custom filter behavior compatible with reloads and saved list settings.
- Patch filter serialization only when the custom field is not a real doctype filter.

## Don't

- Don't prepend custom filters before `ID` or the title/name field.
- Don't add business filters to the page header actions area.
- Don't rely on ad hoc DOM placement that bypasses Frappe's list filter structure.
