# Frappe Icon Picker

## Field Contract

Frappe icon values are plain strings such as `trophy`, `heart-pulse`, or `panels-top-left`. Keep the raw normalized Frappe name in the document; do not persist Flutter code points or SVG markup.

## Trigger And Preview

Render a tappable input with a tinted preview badge, the selected icon name, and a clear action when the field is editable and non-empty. The preview uses the shared `FrappeIcon` renderer and the sibling `icon_color` when available.

## Dialog Requirements

Build a custom `AlertDialog` with:

- Selected icon preview and title.
- Autofocused search field with clear action.
- Responsive icon grid sized from `LayoutBuilder`.
- Loading state while the sprite names are parsed.
- Empty-search state and retryable load-error state.
- Cancel and disabled-until-selected confirmation actions.

Use the shared renderer's `iconNames()` source. Do not maintain a second hardcoded list of Frappe icons in the picker.

## Dynamic Field Detection

Map Frappe's `Icon` field type to a dedicated dynamic field type. For legacy schemas, recognize explicit icon field names such as `icon` and `facility_icon`. Resolve the sibling `icon_color` from the same record/form state rather than passing color through API metadata.

## Save And List Behavior

- Normalize icon names before saving.
- Send the selected name as a normal string field in create and update requests.
- Request icon and paired color fields in listings.
- Render list values through `FrappeIcon`, not `IconData` lookup tables.
- Use a stable fallback icon for missing or obsolete values.
