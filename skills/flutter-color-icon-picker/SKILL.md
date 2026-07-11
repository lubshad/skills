---
name: flutter-color-icon-picker
description: Use when implementing Flutter color pickers and icon pickers for Frappe-backed admin forms, including hex color fields, SVG sprite-based icon selection, and paired color+icon display.
---

Follow these rules when implementing color picker or icon picker widgets in Flutter admin apps.

## Dependencies

```yaml
flex_color_picker: ^3.8.0   # color picker dialog
flutter_svg: any             # SVG rendering for icons from sprite sheets
```

## Color Picker

### Trigger Widget

Build a tappable field that shows a `_ColorPreviewSwatch` (colored circle with border + drop shadow) beside the hex code string. On tap, open a `ColorPicker` dialog from `flex_color_picker`.

```dart
Future<void> _openPicker(BuildContext context) async {
  final initialColor = _parseHexColor(value) ?? AppTheme.primary;
  var selectedColor = initialColor;
  final confirmed = await ColorPicker(
    color: initialColor,
    onColorChanged: (color) => selectedColor = color,
    pickersEnabled: const <ColorPickerType, bool>{
      ColorPickerType.both: false,
      ColorPickerType.primary: false,
      ColorPickerType.accent: false,
      ColorPickerType.bw: false,
      ColorPickerType.custom: true,
      ColorPickerType.customSecondary: false,
      ColorPickerType.wheel: true,
    },
    pickerTypeLabels: <ColorPickerType, String>{
      ColorPickerType.custom: 'Palette',
      ColorPickerType.wheel: 'Custom',
    },
    customColorSwatchesAndNames: _colorPalette,
    enableShadesSelection: true,
    width: 40, height: 40, spacing: 8, runSpacing: 8,
    borderRadius: 10, hasBorder: true,
    showColorCode: true, colorCodeHasColor: true,
    showEditIconButton: true,
    copyPasteBehavior: const ColorPickerCopyPasteBehavior(
      parseShortHexCode: true, editUsesParsedPaste: true,
    ),
    actionButtons: const ColorPickerActionButtons(
      dialogActionButtons: true,
      dialogOkButtonType: ColorPickerActionButtonType.filled,
      dialogCancelButtonType: ColorPickerActionButtonType.filledTonal,
    ),
  ).showPickerDialog(
    context,
    constraints: const BoxConstraints(
      minWidth: 420, maxWidth: 500, minHeight: 520,
    ),
  );
  if (!confirmed) return;
  onChanged(_formatHexColor(selectedColor));
}
```

### Predefined Color Palette

Provide ~10 branded swatches using `ColorTools.createPrimarySwatch`:

```dart
final Map<ColorSwatch<Object>, String> _colorPalette = <ColorSwatch<Object>, String>{
  ColorTools.createPrimarySwatch(Color(0xFF4EA4F8)): 'Default Blue',
  ColorTools.createPrimarySwatch(AppTheme.primary): 'Brand Blue',
  ColorTools.createPrimarySwatch(AppTheme.accent): 'Brand Green',
  ColorTools.createPrimarySwatch(AppTheme.success): 'Success Green',
  ColorTools.createPrimarySwatch(AppTheme.warning): 'Warning Amber',
  ColorTools.createPrimarySwatch(AppTheme.danger): 'Danger Red',
  ColorTools.createPrimarySwatch(Color(0xFF9B59B6)): 'Purple',
  ColorTools.createPrimarySwatch(Color(0xFFE67E22)): 'Orange',
  ColorTools.createPrimarySwatch(Color(0xFF1ABC9C)): 'Teal',
  ColorTools.createPrimarySwatch(Color(0xFFF1C40F)): 'Yellow',
  ColorTools.createPrimarySwatch(AppTheme.textMuted): 'Slate',
};
```

### Color Format

- Store colors as 6-char uppercase hex strings with `#` prefix: `#4EA4F8`.
- Use shared utility functions for parsing and formatting:

```dart
Color? _parseHexColor(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return null;
  var hex = raw.startsWith('#') ? raw.substring(1) : raw;
  if (hex.length == 3) {
    hex = hex.split('').map((part) => '$part$part').join();
  }
  if (hex.length != 6 || !RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return Color(int.parse('FF$hex', radix: 16));
}

String _formatHexColor(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
```

### Preview Swatch Widget

A sized circle with the color, a semi-transparent border, and a drop shadow. Show a `?` icon when the color is invalid (no hex parse).

```dart
Container(
  width: size, height: size,
  decoration: BoxDecoration(
    color: isValid ? color : Colors.transparent,
    borderRadius: BorderRadius.circular(size >= 36 ? 10 : 8),
    border: Border.all(
      color: isValid ? color.withValues(alpha: 0.85) : AppTheme.border,
      width: 1.4,
    ),
    boxShadow: isValid ? [BoxShadow(
      color: color.withValues(alpha: 0.18),
      blurRadius: 8, offset: const Offset(0, 2),
    )] : null,
  ),
  child: isValid ? null : Icon(Icons.question_mark_rounded, size: size * 0.45),
);
```

## Icon Picker

### Trigger Widget

Show an `_IconPreviewBadge` + icon name in a tappable container. Include a close button to clear the value when non-empty and not read-only. On tap, open the icon picker dialog.

Pass the linked `icon_color` value to tint the icon preview:

```dart
final iconColor = _parseHexColor(iconColorHex) ?? AppTheme.primary;
```

### Icon Preview Badge Widget

A tinted container around `FrappeIcon`:

```dart
Container(
  width: size, height: size,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(size >= 36 ? 10 : 8),
    border: Border.all(color: color.withValues(alpha: 0.18)),
  ),
  child: FrappeIcon(
    name: iconName, size: size >= 36 ? 20 : 16, color: color,
  ),
);
```

### Icon Picker Dialog

A custom `AlertDialog` with:
- Title row showing `_IconPreviewBadge` of selected icon + title + close button.
- Search `TextField` with `autofocus: true`, `textInputAction: TextInputAction.search`, clear button when non-empty.
- Responsive `GridView.builder` using `LayoutBuilder` to compute column count based on available width (clamp 3-8 columns, width ~116px per item).
- Error state with retry button for icon load failures.
- Empty state message when search yields no results.
- Loading spinner while icons are being parsed.
- Actions: Cancel + Select Icon (FilledButton, disabled when nothing selected).

```dart
Future<void> _openPicker(BuildContext context, Color iconColor) async {
  final selected = await showDialog<String>(
    context: context,
    builder: (_) => _FrappeIconPickerDialog(
      title: 'Pick $label',
      selectedIcon: FrappeIcon.normalizeName(value),
      iconColor: iconColor,
    ),
  );
  if (selected == null || selected.isEmpty) return;
  onChanged(selected);
}
```

### Icon Picker Card

Each grid tile shows `_IconPreviewBadge` + icon name label. Highlight with border + background tint when selected. Label gets bold weight and accent color when selected, muted otherwise.

## FrappeIcon Widget (SVG Rendering)

### Icon Name Normalization

Normalize legacy FontAwesome icon names before lookup:

```dart
static String normalizeName(String? name) {
  final raw = name?.trim().toLowerCase() ?? '';
  if (raw.isEmpty) return '';
  final withoutStyle = raw
      .replaceFirst('fa-solid ', '').replaceFirst('fa-regular ', '')
      .replaceFirst('fa ', '').replaceFirst('fas ', '').replaceFirst('far ', '');
  final normalized = withoutStyle
      .replaceAll('_', '-')
      .replaceFirst('icon-', '').replaceFirst('fa-', '');
  return _legacyIconNames[normalized] ?? normalized;
}
```

Maintain a `_legacyIconNames` map for Frappe legacy-to-current icon name migration.

### SVG Rendering

Use `FutureBuilder` with `_FrappeIconStore.instance.svgFor()` to get the SVG string, then render via `SvgPicture.string`:

```dart
SvgPicture.string(
  svg, width: size, height: size,
  fit: BoxFit.contain,
  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
);
```

## FrappeIconStore (SVG Sprite Management)

### Architecture

Singleton (`_FrappeIconStore._()` / `static final instance`). Provides two async methods:
- `names()` - returns sorted list of all available icon names.
- `svgFor(iconName, fallbackName, color)` - returns SVG string with colors substituted.

### Sprite Asset Paths

Load from bundled SVG sprite files (Lucide, Timeless, Espresso):

```dart
static const List<String> _assetPaths = <String>[
  'assets/frappe_icons/lucide/icons.svg',
  'assets/frappe_icons/timeless/icons.svg',
  'assets/frappe_icons/espresso/icons.svg',
];
```

### SVG Parsing

Parse `<symbol>` elements with regex. For each symbol, extract `id`, `viewBox`, and body. Strip `icon-` prefix from id. Deduplicate by name (first asset wins). Determine fill-based vs stroke-based by checking asset path for `espresso`.

### Color Substitution

Replace CSS variable references in the SVG body before returning:

```dart
final body = symbol.body
    .replaceAll('var(--icon-stroke)', hex)
    .replaceAll('var(--icon-fill)', hex)
    .replaceAll('currentColor', hex);
```

Wrap in outer `<svg>` with appropriate `fill`/`stroke` attributes depending on icon set type.

### Caching

Lazily load and cache the parsed symbols map using a nullable future:

```dart
Future<Map<String, _FrappeIconSymbol>>? _symbolsFuture;

Future<Map<String, _FrappeIconSymbol>> _loadSymbols() {
  return _symbolsFuture ??= _readSymbols();
}
```

## Frappe Dynamic Field Integration

### Field Detection

```dart
bool _isColorField(FrappeFieldSchema field) {
  return field.fieldName == 'icon_color';
}

bool _isIconField(FrappeFieldSchema field) {
  return field.fieldType == FrappeFieldType.icon ||
      field.fieldName == 'facility_icon' ||
      field.fieldName == 'icon';
}
```

### Frappe Schema Setup

In `FrappeFormSchemaBuilder`, add `'Icon'` to `defaultSupportedFieldTypes`. In the schema builder, resolve the Frappe field type `"Icon"` to `FrappeFieldType.icon`.

### Color-Icon Field Pairing

The icon picker widget reads the sibling `icon_color` field value via `valueOf('icon_color')` to tint the preview. When building dynamic fields, pass this value:

```dart
if (_isIconField(field)) {
  return _IconNameField(
    label: field.label,
    value: value,
    iconColorHex: valueOf('icon_color'),
    onChanged: onChanged,
  );
}
```

### Default Values

Use sensible defaults when values are missing:
- Icon default: `'circle-check'` or `'circle-help'`
- Color default: `'#4ea4f8'`

## Listing Display

In listing table cells, render the icon with its color:

```dart
if (field.fieldType == 'Icon' || field.fieldName.endsWith('_icon')) {
  final colorValue = record.value('icon_color').trim();
  Color? iconColor;
  if (colorValue.isNotEmpty) {
    final hex = colorValue.replaceFirst('#', '');
    final parsed = int.tryParse('ff$hex', radix: 16);
    if (parsed != null) iconColor = Color(parsed);
  }
  return FrappeIcon(
    name: value,
    size: 24,
    color: iconColor ?? AppTheme.primary,
  );
}
```

## CRUD Integration

- Icon and color values are stored as plain string fields on the Frappe DocType (e.g., `facility_icon`, `icon_color`).
- Use standard Frappe REST API endpoints (`/api/resource/{Doctype}`) for read/write.
- Request these fields as `extraFields` in list queries.
- On create/update, send `facility_icon` and `icon_color` as string values in the JSON payload.
- Validate hex color format (6-char hex with `#`) before submitting.
- Use empty-string defaults for icons, send fallback hex color when empty.

## Field Styling

- Color picker trigger: fill background with `color.withValues(alpha: 0.1)`, border with `color.withValues(alpha: 0.3)`, error border uses `AppTheme.danger`.
- Icon picker trigger: use `AppTheme.surface` background, `AppTheme.border` border.
- Both use `BorderRadius.circular(10)` and `InkWell` for tap feedback.
- Error text shown below the field with `AppTheme.danger` color.

## Verification

- Verify icon and color values round-trip through create, edit, and list responses.
- Verify invalid hex input is rejected before the request is sent.
- Verify keyboard and touch selection work at the supported desktop and narrow-screen layouts.
