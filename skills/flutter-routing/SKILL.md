---
name: flutter-routing
description: Use when adding or changing Flutter navigation, routes, route arguments, guards, redirects, or navigator behavior.
---

Follow these routing rules strictly when working on Flutter code.

## Navigation Method

Use `onGenerateRoute` for all navigation. Never use `MaterialPageRoute` directly in UI code.

## Structure

```
lib/
└── core/
    └── app_route.dart      # Central route generator
```

## Rules

### Route Declaration
- The `AppRoute` class lives in its **own file** (`app_route.dart`).
- Each screen declares its route name as a **static constant** on the widget class itself:
  ```dart
  class PlayerDetailScreen extends StatelessWidget {
    static const routeName = '/player-detail';
  }
  ```
- In `AppRoute.onGenerateRoute`, use **direct widget references** to build pages. Do not maintain a global `Map<String, Widget>`.

### Arguments
- Pass only **IDs or minimal data** as route arguments.
- The destination screen fetches its own data — never pass entire model objects through navigation.
- Use typed argument classes when a route needs more than one parameter.

### Named Routes
- **Always navigate via named routes**: `Navigator.pushNamed(context, PlayerDetailScreen.routeName)`.
- Never construct `MaterialPageRoute` inline in widget code.

### Deep Linking
- Keep route names URL-friendly (`/player-detail`, `/match-history`) to support future deep linking.
