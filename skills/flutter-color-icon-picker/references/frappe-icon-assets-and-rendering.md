# Frappe Icon Assets And Rendering

## Dependencies And Assets

Use `flutter_svg` to render Frappe SVG symbols. Bundle the Frappe sprite sheets as Flutter assets:

```yaml
flutter:
  assets:
    - assets/frappe_icons/lucide/icons.svg
    - assets/frappe_icons/timeless/icons.svg
    - assets/frappe_icons/espresso/icons.svg
```

Load Lucide first so identical names resolve to Frappe's primary icon set. Do not fetch icon sprites at runtime.

## Shared Renderer

Put a reusable `FrappeIcon` widget in `lib/core/widgets/`. It receives an icon name, size, color, and fallback name. The widget must:

- Normalize Frappe and legacy FontAwesome names before lookup.
- Lazily parse and cache all `<symbol>` definitions from the bundled sprites.
- Resolve the requested symbol, then `icon-<name>`, then the fallback.
- Render with `SvgPicture.string` and a color filter.
- Reserve its requested size while symbols are loading or missing, so layouts do not shift.

Use `rootBundle.loadString` to load each sprite once. Extract the symbol id, view box, and inner SVG content. For Timeless/Lucide, use stroke rendering; for Espresso's fill-based symbols, use fill rendering.

## Name Normalization

Frappe workspace data commonly contains kebab-case Lucide names, but older records can contain FontAwesome names. Normalize values by:

1. Trimming and lowercasing.
2. Removing `fa-solid`, `fa-regular`, `fa`, `fas`, `far`, `fa-`, and `icon-` prefixes.
3. Converting underscores to hyphens.
4. Applying a small legacy alias map such as `desktop -> monitor` and `futbol -> circle-dot`.

Keep aliases in the shared renderer, not in individual forms or sidebar mappers.

## Color Rendering

Replace `var(--icon-stroke)`, `var(--icon-fill)`, and `currentColor` in the symbol body with the requested color's six-digit hex value. Use the same color for the SVG color filter so sprites with direct paths remain consistently tinted.

## Usage

```dart
FrappeIcon(
  name: workspaceItem.icon,
  size: 20,
  color: Theme.of(context).colorScheme.primary,
)
```

Use a concrete fallback such as `folder-normal` or `circle-help`. Never leave invalid backend icon names as blank visual space.
