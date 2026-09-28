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
- When opening a named route directly on Flutter web, account for earlier routes (such as `/` or splash) that may remain mounted underneath it.

### Route Lifecycle And Auth Redirects
- Before navigating from a BLoC listener, timer, or delayed callback, check that the owning route is still mounted and current (for example, `mounted && ModalRoute.of(context)?.isCurrent == true`). An offstage splash or login route must not redirect over the active page.
- Scope startup-session navigation to the startup check. Do not treat a later login, signup, or OTP error as a reason for the splash route to navigate again.
- Consume pending navigation results once so a later timer or state change cannot repeat the same redirect. Keep form state intact when a recoverable request fails.

## Verification

- Open an auth route directly by URL, trigger a failed login or OTP request, and confirm the current route and entered values remain intact.
- Confirm the splash route still navigates after the startup session check, and an expired authenticated session still returns to login.
