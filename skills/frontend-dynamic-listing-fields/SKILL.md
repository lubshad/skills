---
name: frontend-dynamic-listing-fields
description: Use when listing columns, filters, search fields, or sort choices come from metadata/schema.
---

# Dynamic Listing Fields

Owns schema-selected columns/search/filter/sort, not architecture, navigation, actions, pagination widgets, header, refresh, or general API contracts. Read `frontend-admin-panels.md` → `frontend-listing-screens.md` → `frontend-ui-states.md` → this skill → listing platform adapter.

## Applied metadata, not raw schema

Build columns from `in_list_view`, identity/title fields, indicators, and list settings such as `add_fields`. For custom Frappe admins use **applied runtime metadata** reflecting Property Setters/Custom Fields; raw DocType flags can disagree with Desk. Keep actions/selection separate, skip hidden/internal fields unless explicitly needed, use metadata header labels, and keep horizontal overflow inside the table.

## Queries and filters

Search/filter is API-backed, never an unbounded client dataset. Top filters use `in_standard_filter`; full Desk-style filter pickers include applied readable/value metadata plus `name`, `owner`, `creation`, `modified`, `modified_by`. Picker choices are searchable local metadata, not remote requests. Global search uses `search_fields`; default sort uses `sort_field`/`sort_order`. Exposed sort choices include system `modified/name/creation/idx`, title/default-sort, and required/bold/list fields.

Query/filter/sort changes reset page one. Debounce per-character inline text `onChanged`. Exposed text operators include Equals/Like; full popovers derive operators by type and retain them in payloads. Link values use async selectors for `options` DocType, not static dropdowns. Apply Desk-compatible like/not-like wildcards; send lists for in/not-in/Between, not raw comma strings.

## Cell-to-filter

Only nonempty **secondary rendered value items** toggle `=` using raw values; repeating the same field/value removes that filter. First/subject column remains identity/detail navigation. Surrounding cell whitespace keeps normal row/detail behavior; never steal checkbox/actions/View/Edit/Delete. Empty/fallback `Not set` and Attach/Image/Table/Button/HTML layout fields are not filter targets.

## Rendering

- Data/Link/Select: text cells; appropriate text/searchable-link filters.
- Small Text/Text/Text Editor: truncated text; filter only if product/metadata supports it.
- Date/Datetime: formatted values; supported date/range filters.
- Int/Float/Currency/Percent: right-aligned; supported numeric filters.
- Check: compact boolean cell/filter.
- Attach/Attach Image/Table: excluded by default unless explicitly needed.

Missing values use clear `Not set`-style fallback.

## Verification

Compare columns to applied metadata **plus settings**, including Desk customizations, before calling mismatches UI bugs. Check metadata filters/search, backend operators/sort/page resets, and existing pagination/refresh/add/navigation/delete/selection/state behavior. Run platform formatter/analyzer/linter.
