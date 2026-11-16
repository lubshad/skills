---
name: frontend-dynamic-tabs-fields
description: Use when detail tabs, sections, controls, visibility, or required state are generated from schema.
---

# Dynamic Detail Fields

Owns schema-driven rendering/visibility/required state, not save flow, architecture, page chrome/overview, uploads, or general API contracts. Read `frontend-admin-panels.md` → `frontend-forms.md` → `frontend-ui-states.md` → `frontend-admin-detail-pages.md` → this skill → form adapter.

## Load once, in parallel

Start metadata at parent detail opening alongside record fetch, not after loaded-record form mounting. Reuse that future for the form; parent replaces it on retry. Record values and layout/control/dependency schema remain separate.

## Layout

Map Tab Break/Section Break to tabs/sections with existing shared dynamic-tab and accent/underline section-title components. Column Break is layout, not data. Skip hidden/internal fields unless required, unsupported layout-only controls, and empty sections/tabs after visibility filtering. Product-defined tabs override dynamic tab policy when explicitly requested; fields may remain dynamic. Preserve drafts across tabs.

## Controls

- Data: text with `options` hints (Email/Phone/URL/IBAN).
- Small Text/Text/Text Editor: multiline; rich editor only if already supported.
- Date: picker plus app-formatted text; Datetime/Time: supported native picker, otherwise validated text.
- Int: integer; Float/Currency/Percent: decimal; Check: platform checkbox/switch/toggle.
- Select: newline metadata options, empty/clear when optional.
- Link: searchable native selector using `options`, not remote dropdown.
- Attach Image/Attach: preview/select/remove only when that upload scope is requested.
- Table: compact read-only summaries unless child editing is explicit.

Frappe hex fields (especially Data `icon_color`) need editable hex, visible swatch, and palette/custom picker; normalize `#RRGGBB`, retaining draft on cancellation.

## Dependencies

Recompute `depends_on` visibility and `reqd`/`mandatory_depends_on` required state from every draft change. Hidden fields are not required-validated. Support common `doc.field`, negation, equality/inequality to values, `&&`, `||`, and `doc.__islocal`. Unsupported expressions default visible and do not block saves with unsupported conditional validation unless stricter behavior is explicitly required.

## Verification

Compare layout/control mappings to metadata; check hidden/empty suppression, draft retention, reactive visibility/required expressions and fallback behavior. Run platform formatter/analyzer/linter.
