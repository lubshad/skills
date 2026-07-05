---
name: frontend-dynamic-listing-fields
description: Use when frontend listing columns, filters, search fields, or sort options are generated from metadata or schema.
---

Use this skill for frontend listing/index screens whose columns, filters, search fields, or sort options are rendered from metadata, schema, or Frappe Desk list settings.

## Scope

Apply this when building or refactoring admin listing/table/index pages where visible columns and top filters come from Frappe DocType metadata, Frappe listview settings, or another list schema.

This skill owns only dynamic listing field selection, column rendering, filter/search controls, and sort-option behavior. It does not own repository architecture, BLoC/state architecture, routing, row actions, pagination widgets, page headers, refresh behavior, or API contracts except where metadata is needed to choose fields and operators.

## Reading Order

For dynamic admin listings, read these first:

1. `frontend-admin-panels.md`
2. `frontend-listing-screens.md`
3. `frontend-ui-states.md`
4. This file
5. Platform adapter such as `flutter-listing-screens.md`, `nextjs-listing-screens.md`, or other implementation-specific guidance

## Column Selection

- Build visible columns from schema metadata such as Frappe `in_list_view`.
- For Frappe-backed custom admin apps, read the applied runtime metadata, not the raw `DocType` resource, when list columns must reflect Property Setters, Custom Fields, or Desk-visible customizations. The raw `DocType` document can still show upstream field flags after a property setter changes Desk behavior.
- Include platform/list-view settings that alter visible columns, such as Frappe `listview_settings[doctype].add_fields`.
- Include identity/title fields needed for navigation and row display, such as `name` and `title_field`, even when they are not ordinary metadata columns.
- Do not assume Frappe Desk columns equal only raw `in_list_view`; Desk can combine DocType metadata, title fields, indicator fields, and listview settings.
- Keep app-owned action/selection columns separate from metadata columns.
- Skip hidden/internal fields unless product behavior explicitly needs them.
- Use metadata labels for headers and keep table width responsive; if columns overflow, scroll horizontally inside the table region.

## Search, Filters, And Sort

- Use backend/API-backed search and filtering. Do not fetch an unbounded dataset and filter it only in the client.
- Build top filters from metadata such as Frappe `in_standard_filter`.
- When building a Frappe-Desk-style custom Filter popover, do not limit the field picker to `in_standard_filter`; include readable/value fields from applied DocType metadata plus standard fields such as `name`, `owner`, `creation`, `modified`, and `modified_by`.
- Use metadata `search_fields` for global or field-backed search behavior.
- Use metadata `sort_field` and `sort_order` for the default sort.
- Build sort options from system fields such as `modified`, `name`, `creation`, `idx`, plus title, default sort, required/bold/list-view fields when the platform exposes sort selection.
- Reset pagination to page 1 whenever search, filters, or sort changes.
- For metadata-driven inline text filters (including list filters rendered from `in_standard_filter` or user-added fields), debounce `onChanged` updates so filtering reacts per character.
- For text fields, support explicit operators such as `Equals` (`=`) and `Like` (`like`) when the UI exposes operator selection.
- For custom filter popovers, make operators dynamic by field type, matching Frappe Desk filter behavior instead of hardcoding only `Equals` and `Like`. Preserve selected operators in the API filter payload.
- For custom filter popovers, use a searchable field picker when choosing the field to filter. The picker should be backed by the local applied metadata field list plus standard fields, not by a network request for field choices.
- For Link filters, use a searchable selector backed by the linked doctype from `options`; do not use a static dropdown for network-bound links.
- For `like` and `not like`, apply wildcard behavior consistently with Frappe Desk. For `in`, `not in`, and `Between`, send list values instead of a single raw comma string.
- In Frappe-style dynamic table rows, visible value items should be filterable like Desk: clicking the rendered non-empty value text/chip applies or replaces an `=` field filter for that item's raw value. If the same `=` field/value filter is already active, clicking the value item should remove that field filter. Do not use formatted display text as the filter value.
- Do not make the first visible/subject column filterable. Frappe Desk reserves the subject column for identity and form/detail navigation; apply cell-to-filter only to secondary value columns.
- Cell-to-filter interactions must not make the whole cell/column area a filter target. Only the rendered value item should filter; surrounding whitespace in the cell should preserve the normal row/detail click behavior.
- Cell-to-filter interactions must not steal checkbox, row action, or explicit View/Edit/Delete controls. Keep a separate detail navigation path, and only make real value items filterable.
- Do not apply cell filters for empty values, displayed fallbacks such as `Not set`, or non-value fields such as Attach/Image/Table/Button/HTML layout fields.

## Field Rendering

Map field types to list cells and filter controls before falling back to plain text:

| Field type | Listing behavior |
|------------|------------------|
| `Data`, `Link`, `Select` | Text cell; text filter or searchable link selector as appropriate. |
| `Small Text`, `Text`, `Text Editor` | Truncated text cell; text filter only if product/metadata marks it filterable. |
| `Date`, `Datetime` | Formatted date/time cell; date or date-range filter if supported. |
| `Int`, `Float`, `Currency`, `Percent` | Right-aligned numeric cell; numeric filter if supported. |
| `Check` | Compact yes/no or check state; boolean filter. |
| `Attach`, `Attach Image`, `Table` | Do not render by default unless product behavior explicitly asks for it. |

Use a clear fallback such as `Not set` for missing values.

## Verification

- Compare rendered columns against metadata plus list-view settings, not metadata alone.
- For Frappe-backed dynamic listings, verify against the applied Frappe meta that Desk uses, including Property Setters and Custom Fields, before concluding a frontend column mismatch is a UI bug.
- Verify standard filters and search fields come from metadata/list schema.
- Verify text operators generate the matching backend operators.
- Verify sort defaults and sort changes affect backend order and reset pagination.
- Verify app-owned listing behavior still works: pagination, refresh, add, row tap, view/delete, checkbox selection, loading, empty, and error states.
- Run the platform formatter and analyzer/linter after implementation.
