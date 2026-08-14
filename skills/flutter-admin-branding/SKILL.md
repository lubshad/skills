---
name: flutter-admin-branding
description: Use when adding or updating branding for Flutter admin or back-office apps, including logo, splash, favicon, PWA metadata, and shell colors.
---

Use this skill when adding or updating branding for a Flutter admin or back-office app.

Apply it for:
- Rebranding an existing Flutter admin app.
- Adding or changing product name, logo, favicon, splash, login identity, sidebar/header identity, PWA metadata, or admin shell brand colors.
- Branding Flutter web admin apps under `flutter_apps/*_admin/` or equivalent admin Flutter surfaces.

Do not use this for Frappe Desk branding; use `frappe-app-branding.md` instead.
Do not use this for consumer/mobile Android and iOS app icon or native splash branding; use `flutter-mobile-branding.md` instead.

## Reading Order

- Read `frontend-admin-panels.md` first for back-office product intent.
- Read `frontend-auth-entry-ui.md` before changing login, signup, OTP, forgot-password, or account access UI.
- Read `frontend-device-layout.md` for desktop-first admin layout and mobile fallback rules.
- Read `flutter-architecture.md` for feature boundaries, shell structure, entry points, and global app setup.
- Read `flutter-common-widgets.md` before creating or replacing shared logo/brand widgets.
- Read `flutter-theming.md` before changing colors, fonts, animations, or `ThemeData`.
- Read `flutter-linting.md` before verification.
- Read `project-connections.md` when branding scope includes deployment hosts, API base URLs, app links, or environment config.

## Branding Scope

Update visible brand surfaces that belong to the Flutter admin shell:

- Product/app title shown in `MaterialApp`, environment entry points, splash, login, sidebar, and header identity.
- Logo and favicon assets, including PWA icons and any reusable logo mark widget.
- Browser metadata in `web/index.html` and install metadata in `web/manifest.json`.
- Theme colors, focus/selection colors, loader colors, and sidebar/header identity colors.
- Visible fallback admin email/name strings, error text, and reserved-area copy when they are user-facing.

Keep domain module labels, routes, data model names, and API contracts unchanged unless the task explicitly requests a product/domain rename.

## Mandatory Shell Surfaces

Every Flutter admin branding pass must explicitly review and update these surfaces:

- Splash screen: logo, product name, subtitle/status copy, background, loader/accent colors, and any animation glow/shadow colors.
- Login page: desktop brand panel, mobile form header, logo, product name, positioning copy, feature/status chips, submit context, focus colors, and debug/fallback credentials if visible.
- Admin sidebar: expanded title, collapsed logo mark, logo semantics/tooltips, selected-item accent color, sidebar background, and logout/control colors.

If the app does not have one of these surfaces, note that in the final response and do not create a new surface unless the task asks for it.

## Flutter Asset Rules

- Put app-owned brand images under `assets/images/` and declare them in `pubspec.yaml`.
- Keep a reusable brand/logo widget in `lib/core/widgets/`; one public widget per file with a snake_case filename.
- Prefer raster PNG assets for Flutter/web app icons and favicon when the app does not already support SVG rendering.
- If converting a source SVG or remote brand asset, keep the resulting asset dimensions stable and verify Flutter can resolve them.
- Do not add new image/font dependencies solely for branding when existing Flutter and platform tooling can produce the required assets.

## Compatibility Boundaries

Do not rename these unless explicitly requested:

- Flutter package name.
- Dart class names that are compatibility or architecture identifiers.
- Route names, deep links, generated platform identifiers, or bundle IDs.
- Shared preference keys or local storage keys.
- API base URLs, backend site URLs, auth endpoints, or deployment hosts.
- Existing data models and domain modules.

When a compatibility identifier contains the old brand, leave it in place and prefer updating only visible text and user-facing assets.

## Implementation Checklist

- Centralize brand constants in the existing theme/config layer before replacing scattered literals.
- Replace visible brand strings with constants where practical, especially product name, default email, and app title.
- Keep admin screens dense, scannable, and workflow-focused; do not turn the admin shell into a landing page.
- Keep auth screens in the two-section desktop/tablet layout from `frontend-auth-entry-ui.md`, with a form-focused mobile fallback.
- Use only bundled/local fonts declared in `pubspec.yaml`; do not use Google Fonts.
- Preserve existing BLoC, repository, route, and navigation-shell behavior.
- Avoid touching unrelated feature screens unless they display shell-level brand identity.

## Verification

After implementation:

- Run `flutter analyze` from the Flutter app directory.
- Search `lib/`, `web/`, and `pubspec.yaml` for old visible brand strings.
- Confirm `pubspec.yaml` declares all new assets used by widgets or web metadata.
- For changed favicon/PWA/logo assets, run a debug web build when needed to verify asset resolution.
- Manually inspect splash, login desktop, login mobile width, and sidebar expanded/collapsed states when a browser or screenshot workflow is available.
