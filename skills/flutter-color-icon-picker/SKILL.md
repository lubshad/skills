---
name: flutter-color-icon-picker
description: Use when implementing Frappe-backed Flutter color/icon pickers, paired previews, or SVG sidebar icons.
---

# Flutter Color and Icon Pickers

Use `flex_color_picker: ^3.8.0` and `flutter_svg`. Read by implementation branch:

- Rendering/assets/normalization/cache: [shared icon renderer](references/frappe-icon-assets-and-rendering.md).
- Color parsing/storage/picker: [color field](references/frappe-color-picker.md).
- Search/dialog/dynamic fields/CRUD: [icon picker](references/frappe-icon-picker.md).
- Navigation mapping/overrides: [sidebar icons](references/frappe-sidebar-icons.md).

## Color contract

Store uppercase `#RRGGBB`; shared parsing accepts trimmed optional-hash three/six-digit hex, expands shorthand, and rejects invalid characters/length. Formatting uses RGB from `toARGB32()`, discarding alpha. Show editable hex plus bordered/shadowed swatch; invalid values show `?`. Commit picker changes only on confirmation.

Provide about ten branded `ColorTools.createPrimarySwatch` colors (default/brand blue, accent/success green, warning, danger, purple, orange, teal, yellow, slate). Enable Palette/custom and wheel with shades/code/edit/copy-paste, including short-hex parsing; disable other picker types. Example sizing: 40px swatches, 8px gaps, 10px radius; dialog width 420–500/min-height 520. Filled OK/tonal Cancel.

## Icons and storage

Triggers show tinted `FrappeIcon` badge/name and an editable-only clear action. Dialog has preview/title/close, autofocus search with search action/clear, `LayoutBuilder` grid (3–8 columns, about 116px/item), loading, empty, retry, Cancel, and disabled-until-selected Filled confirmation. Selected cards use border/background tint, bold accent labels; others muted. Null/empty dialog results do not change values.

`FrappeIconStore` is a lazy singleton with cached symbol future, sorted `names()` and `svgFor(name, fallback, color)`. Parse symbol ID/viewBox/body; first bundled asset wins; Espresso is fill-based, Lucide/Timeless stroke-based. Substitute CSS color variables/currentColor before wrapping/rendering via `FutureBuilder`/`SvgPicture.string` with `BoxFit.contain` and `BlendMode.srcIn`. Keep legacy alias normalization shared.

Add `Icon` to schema supported types and map to `FrappeFieldType.icon`; recognize `icon`/`facility_icon` and color `icon_color`. Resolve sibling color through draft `valueOf('icon_color')`. Missing defaults: `circle-check`/`circle-help`, color `#4EA4F8`; invalid/missing previews fall back to primary. List `Icon`/`*_icon` fields through the renderer (example size 24).

Use normal `/api/resource/{Doctype}` strings and request icon/color as `extraFields`. Send icon empty-string defaults and fallback hex when empty; validate submitted hex.

## Styling and verification

Color triggers: fill alpha .1, border .3; swatches border .85/1.4px and shadow .18/blur 8/offset (0,2). Icon badges: fill .12, border .18; trigger surface/border tokens. Badge radius 10 at ≥36px, otherwise 8; icon sizes 20/16. Triggers use 10px radius/`InkWell`; errors use `AppTheme.danger` below the field.

Verify create/edit/list round-trips, pre-request invalid-hex rejection, and keyboard/touch selection at desktop/narrow widths.
