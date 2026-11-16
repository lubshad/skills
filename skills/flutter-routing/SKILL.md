---
name: flutter-routing
description: Use when changing Flutter routes, arguments, guards, redirects, or navigator behavior.
---

# Flutter Routing

Use named navigation (`Navigator.pushNamed(context, PlayerDetailScreen.routeName)`) through `AppRoute.onGenerateRoute` in `lib/core/app_route.dart`. Screens declare URL-friendly static route constants. The generator builds direct widget references, not a global widget map; UI never constructs `MaterialPageRoute` inline.

Pass IDs/minimal data, using typed arguments for multiple parameters. Destinations fetch their own models.

## Lifecycle

Web deep links may leave `/` or splash mounted underneath. Before BLoC-listener, timer, or delayed navigation, require the owning route to be mounted and current (`mounted && ModalRoute.of(context)?.isCurrent == true`). Offstage startup/login routes must not redirect over active pages.

Startup-session navigation belongs only to that check, not later login/signup/OTP failures. Consume pending navigation results once; preserve form values on recoverable failure.

## Verification

Open an auth URL directly, fail login/OTP, and confirm route and input preservation. Check startup-session navigation and expired-session return to login.
