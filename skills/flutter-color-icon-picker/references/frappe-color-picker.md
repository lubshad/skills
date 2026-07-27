# Frappe Color Picker

## Storage Contract

Store colors in Frappe string fields as uppercase six-digit hex values with a leading hash:

```text
#4EA4F8
```

Use the same format in form state, API payloads, list records, and dynamic field values.

## Parsing And Formatting

Use shared helpers. Accept three-digit input when reading, but always write six-digit output.

```dart
Color? parseHexColor(String? value) {
  var hex = value?.trim() ?? '';
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 3) {
    hex = hex.split('').map((part) => '$part$part').join();
  }
  if (hex.length != 6 || !RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
    return null;
  }
  return Color(int.parse('FF$hex', radix: 16));
}

String formatHexColor(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
```

## Field Behavior

- Display a tinted preview swatch and the current hex value in a tappable field.
- Use `flex_color_picker` for palette and custom-color selection.
- Provide a branded palette plus wheel/custom entry.
- Keep the current value until the user confirms the dialog.
- Show an invalid-value indicator instead of silently replacing malformed data.
- Do not open the picker for read-only fields.

## Frappe Icon Pairing

For an `icon` field paired with `icon_color`, use the parsed `icon_color` to tint all previews. A missing or invalid color should fall back to the application primary color, not block saving unrelated form values.

## Listing And CRUD

Request color fields alongside icon fields in list queries. Send color values as ordinary JSON strings through the normal Frappe resource API. Validate a user-entered color before submit, but preserve the value in the form so it can be corrected.
