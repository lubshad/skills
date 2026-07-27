# Frappe Sidebar Icons

## Backend Contract

Workspace Sidebar API items should expose the configured Frappe `icon` string without converting it to a frontend-specific value. Preserve the name on the Flutter workspace-sidebar model together with label, type, link type, target, and child/group information.

## Default And Override Rule

Use the Frappe icon as the default sidebar visual. Allow route-specific Flutter `IconData` overrides only when an application has a concrete visual requirement that the configured Frappe icon cannot meet.

```dart
class NavigationDestinationItem {
  final String? frappeIconName;
  final IconData? flutterIconOverride;
}
```

The renderer chooses the Flutter override first, then the Frappe icon, then a shared Frappe fallback:

```dart
if (flutterIconOverride != null) {
  return Icon(flutterIconOverride, size: size, color: color);
}
return FrappeIcon(
  name: frappeIconName,
  size: size,
  color: color,
);
```

## Mapping

Keep application route mapping separate from icon selection. The mapper should take `WorkspaceSidebarItem.icon` from the API and attach it to the matched navigation destination. For exceptional destinations, use a small frontend override registry keyed by stable `link_type:link_to` pairs.

```dart
static const Map<String, IconData> flutterIconOverrides = {
  // 'Page:custom-dashboard': Icons.dashboard_rounded,
};
```

Section Breaks also carry Frappe icon names and should use the same renderer. Child entries use the configured backend icon when present; otherwise the shared fallback prevents layout shifts.

## Do Not Do This

- Do not turn Frappe icon names into hardcoded Flutter icon switches.
- Do not persist Flutter overrides to Frappe.
- Do not load sprite files per sidebar row.
- Do not omit a fallback for missing or legacy icon names.
