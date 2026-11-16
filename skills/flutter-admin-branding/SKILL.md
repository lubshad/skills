---
name: flutter-admin-branding
description: Use when branding Flutter admin logos, splash/login/sidebar surfaces, favicons, PWA metadata, or shell colors.
---

# Flutter Admin Branding

For Desk use `frappe-app-branding.md`; for consumer icons/native splash use `flutter-mobile-branding.md`.

Read `frontend-admin-panels.md` and `frontend-device-layout.md` first. Auth changes also need `frontend-auth-entry-ui.md`. Then apply `flutter-architecture.md`, `flutter-common-widgets.md` for shared logos, `flutter-theming.md` for visual tokens, and `flutter-linting.md`. Hosts/links/environment changes need `project-connections.md`.

## Brand surfaces

Review and update visible titles in all entrypoints/`MaterialApp`, splash/login/sidebar/header, logo/favicon/PWA assets, `web/index.html`, `web/manifest.json`, theme/focus/selection/loader colors, and visible fallback identity/error/reserved-area copy.

Mandatory review:
- Splash: logo, name, subtitle/status, background, loader, glow/shadow.
- Login: desktop panel/mobile header, identity, positioning, chips, submit/focus styling, visible debug/fallback credentials.
- Sidebar: expanded title, collapsed mark, semantics/tooltips, selected accent, background, logout/control colors.

Report absent surfaces; do not create them without scope.

## Boundaries

Centralize brand constants in existing theme/config. Reuse a snake_case, single-public-widget logo in `lib/core/widgets/`. Put images in `assets/images/`, declare them in `pubspec.yaml`, and prefer PNG where SVG is unsupported. Preserve dimensions and verify converted/remote assets resolve. Add no image/font dependency solely for branding; use bundled fonts.

Keep admin density, two-section wide auth, and form-focused mobile fallback. Preserve BLoC/repository/navigation behavior and unrelated screens. Unless explicitly requested, keep domain labels/models, package/class identifiers, routes/deep links, bundle/platform IDs, storage keys, API/auth/site URLs, and deployment hosts—even when identifiers retain the old brand.

## Verification

Run `flutter analyze`; search `lib/`, `web/`, and `pubspec.yaml` for old visible names and missing asset declarations. Debug web-build changed favicon/PWA/logo assets when needed to check resolution. Inspect splash, wide/narrow login, and expanded/collapsed sidebar when runtime/screenshots are available.
