---
name: frontend-dynamic-tabs-fields
description: Use when frontend detail forms render tabs, sections, or fields from Frappe DocType metadata or another schema.
---

Use this skill for frontend detail forms whose tabs, sections, or fields are rendered from metadata or schema.

## Scope

Apply this when building or refactoring admin detail/profile/edit pages where the visible form structure comes from Frappe DocType metadata or another field schema.

This skill owns only tab, section, field rendering, field visibility, and field required-state behavior. It does not own save flow, repository design, BLoC/state architecture, page headers, right overview rails, uploads, or API contracts except where metadata is needed to choose a field control.

## Metadata Loading

- Start form metadata/schema loading as early as the detail page opens, in parallel with the record fetch.
- Do not defer metadata loading until the record-loaded form widget is mounted; that creates a delayed second loading phase where secondary panels can render before the main form.
- Reuse the same metadata/schema future for the form instance once the record is available.
- On metadata retry, replace the shared metadata/schema future from the parent detail view and let the form rebuild from that future.
- Keep record data and metadata separate: record fetches provide values, while metadata fetches provide tabs, sections, fields, visibility rules, and field controls.

## Reading Order

For admin detail forms, read these first:

1. `frontend-admin-panels.md`
2. `frontend-forms.md`
3. `frontend-ui-states.md`
4. `frontend-admin-detail-pages.md`
5. This file
6. Platform adapter such as `flutter-forms.md`, `nextjs-forms.md`, or other implementation-specific guidance

## Tab And Section Rendering

- Build tabs from schema layout fields such as Frappe `Tab Break`.
- Build sections from schema layout fields such as Frappe `Section Break`.
- Render metadata-backed tabs with the platform's shared dynamic-detail tab component when one exists, rather than rebuilding per-feature tab bars.
- Render section headings with the platform's shared form-section title component when one exists, including the established accent/underline treatment.
- Treat `Column Break` as layout guidance only; do not model it as a data field.
- Skip hidden/internal fields unless product behavior explicitly needs one.
- Skip empty tabs and empty sections after visibility filtering.
- Product intent can override metadata tab policy. If the user says tabs do not need dynamic rendering, keep tabs product-defined and render only fields dynamically inside those tabs.
- Preserve draft values when moving between tabs.

## Field Rendering

Map schema field types to controls before falling back to generic text input:

| Field type | Control |
|------------|---------|
| `Data` | Single-line text input. Use `options` for keyboard and validation hints such as `Email`, `Phone`, `URL`, or `IBAN`. |
| `Small Text`, `Text`, `Text Editor` | Multiline input. Use rich text/editor behavior only if the platform already supports it. |
| `Date` | Date picker plus text representation in the app's date format. |
| `Datetime`, `Time` | Platform-appropriate date/time picker if the app supports it; otherwise use validated text input. |
| `Int` | Integer numeric input. |
| `Float`, `Currency`, `Percent` | Decimal numeric input. |
| `Check` | Checkbox, switch, or toggle matching the platform form pattern. |
| `Select` | Inline select/dropdown from newline-separated metadata options. Include a clear/empty value when the field is optional. |
| `Link` | Searchable selector/dialog/screen using the linked doctype from `options`. Do not use a simple dropdown for network-bound links. |
| `Attach Image` | Image preview with select/remove controls only if image selection is in scope. |
| `Attach` | File select/remove control only when generic file selection is in scope. |
| `Table` | Compact read-only row summaries unless child-table editing is explicitly requested. |

- For metadata-backed Frappe hex color fields, especially `Data` fields named `icon_color`, do not render only raw hex text. Render a controlled color field that keeps the hex input editable, shows a visible color swatch preview in the field, and opens the platform color picker for palette/custom selection. Persist values as normalized `#RRGGBB` strings and do not update the draft when the picker dialog is cancelled.

Do not render unsupported layout/control-only metadata as editable fields.

## Visibility And Required State

- Use metadata `depends_on` to hide or show fields from current draft values.
- Use metadata `reqd` for base required state.
- Use metadata `mandatory_depends_on` for conditional required state.
- Recompute visibility and required state whenever draft values change.
- Do not validate hidden fields as required.

Support common Frappe dependency expressions used in form metadata:

- `doc.field`
- `!doc.field`
- `doc.field == "Value"`
- `doc.field != "Value"`
- `&&`
- `||`
- `doc.__islocal`

If a dependency expression is more complex than the local evaluator supports, keep the field visible by default and avoid blocking save with unsupported conditional validation unless the product explicitly requires stricter behavior.

## Verification

- Compare generated tabs and sections against the source metadata.
- Verify hidden fields, empty tabs, and empty sections do not render.
- Verify every supported field type renders the intended control.
- Verify `depends_on` and `mandatory_depends_on` respond to draft changes.
- Run the platform formatter and analyzer/linter after implementation.
