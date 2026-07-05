---
name: flutter-mobile-branding
description: Use when branding Flutter mobile apps with flutter_launcher_icons, flutter_native_splash, Android/iOS app icons, native launch image, display names, in-app splash, auth identity, or theme colors.
---

# Flutter Mobile Branding

Use this skill when adding or updating branding for a Flutter mobile app.

Apply it for:
- Rebranding consumer/customer Flutter apps under `flutter_apps/*/` or `omor/omor_app/`.
- Adding or changing Android and iOS app icons.
- Adding or changing native launch images and splash screens through `flutter_native_splash`.
- Updating Android and iOS app display names.
- Updating in-app splash, login, signup, OTP, onboarding, and customer-facing brand identity.
- Updating `MaterialApp.title`, `ThemeData`, app logo widgets, and visible brand text.

Do not use this for Flutter admin/back-office web shell branding; use `flutter-admin-branding.md` for that. Do not use this for release automation unless branding work also touches release scripts; use `flutter-android-release.md` or `flutter-ios-release.md` for store/release setup.

## Gather Inputs First

Before executing branding changes, inspect the app briefly, then collect every missing branding detail from the user with the `question` tool. Do not guess brand names, descriptions, colors, typography, icon paths, or display-name behavior.

Required inputs:

- App name shown to users.
- App description, subtitle, or short product tagline shown on splash/auth/onboarding surfaces.
- App icon asset path. The expected default is `assets/pngs/app_icon.png`.
- In-app splash screen background color.
- Native launch screen background color used by `flutter_native_splash`.
- Primary brand color.
- Secondary/accent brand color.
- Typography or font preference, including whether to keep the existing app typography.
- Whether auth screens should show the app description/tagline.
- Whether Android and iOS display names should both use the same app name.

If any required detail is missing, ask before editing. If `assets/pngs/app_icon.png` is missing, stop and ask the user to provide that file or confirm another existing asset path. Do not continue with generated icons or splash screens until a valid source asset is available.

Use concise `question` tool prompts. Prefer selectable options for common choices and allow custom answers. Example question set:

- App name: ask for the visible app name.
- App description: ask for a short splash/auth tagline.
- App icon: offer `assets/pngs/app_icon.png` as the recommended path and allow another path.
- Splash background: ask for a hex color for the in-app splash screen.
- Launch background: ask for a hex color for native launch screens, with an option to reuse the splash color.
- Colors: ask for primary and accent hex colors.
- Typography: offer `Keep existing`, `Use system font`, or a custom font name.
- Auth identity: ask whether login/signup/OTP screens should display the description.
- Display names: ask whether Android and iOS should both use the same app name.

Proceed only after the answers are sufficient to make deterministic changes.

## Execution Flow

Follow this order:

1. Identify the Flutter mobile app root and current branding surfaces.
2. Check whether `assets/pngs/app_icon.png` exists, or validate the user-confirmed alternate asset path.
3. Ask the user for every missing required branding detail with the `question` tool.
4. Update `pubspec.yaml` assets and generator configuration.
5. Update Android and iOS visible display names only.
6. Update `flutter_native_splash` configuration with the chosen launch background color.
7. Update in-app splash, auth identity, visible brand text, theme colors, and typography according to the collected inputs.
8. Run `flutter pub get`, `dart run flutter_launcher_icons`, and `dart run flutter_native_splash:create` from the Flutter app root.
9. Verify generated assets, visible strings, and analysis results.

## Read With

- `frontend-auth-entry-ui.md` before changing login, signup, OTP, forgot-password, or account access UI.
- `flutter-architecture.md` for feature boundaries, entry points, and global app setup.
- `flutter-common-widgets.md` before creating or replacing shared logo/brand widgets.
- `flutter-theming.md` before changing colors, fonts, animations, or `ThemeData`.
- `flutter-linting.md` before verification.
- `flutter-utilities.md` when changing splash/auth flow behavior, app environment config, or run scripts.
- `flutter-android-release.md` only when Android release/build/signing setup changes.
- `flutter-ios-release.md` only when iOS release/archive/App Store setup changes.

## Branding Scope

Review and update these surfaces when applicable:

- Source brand asset under `assets/`, preferably a square PNG of at least `1024x1024` for app icons.
- `pubspec.yaml` asset declarations and generator package configuration.
- Android launcher icons and adaptive icons generated under `android/app/src/main/res/`.
- iOS app icons generated under `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.
- Android native launch background and Android 12 splash files generated by `flutter_native_splash`.
- iOS native launch splash files and `Info.plist` updates generated by `flutter_native_splash`.
- Android display name in `android/app/src/main/AndroidManifest.xml`.
- iOS display name in `ios/Runner/Info.plist`.
- `MaterialApp.title` in every app entry point, such as `lib/main.dart`, `lib/main_dev.dart`, and `lib/main_prod.dart`.
- In-app splash screen logo, product name, subtitle/status copy, loader/accent colors, and minimum-splash behavior.
- Auth screens: login, signup, OTP, reset/forgot-password, onboarding, and any mobile form header that displays brand identity.
- Theme colors, focus/selection colors, loader colors, and app bar/navigation colors.

Keep API contracts, routes, storage keys, package names, and bundle identifiers unchanged unless the user explicitly requests a compatibility-breaking rename.

## Required Packages

Use packages for generated platform assets instead of manual resizing:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.4
```

Run `flutter pub get` after adding the packages.

## Standard Pubspec Configuration

Use the app's actual asset path and brand colors. Example:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/pngs/app_icon.png

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/pngs/app_icon.png"
  adaptive_icon_background: "#0A2540"
  adaptive_icon_foreground: "assets/pngs/app_icon.png"
  remove_alpha_ios: true

flutter_native_splash:
  color: "#0A2540"
  image: assets/pngs/app_icon.png
  android: true
  ios: true
  android_12:
    color: "#0A2540"
    image: assets/pngs/app_icon.png
```

If the icon has transparency or an intricate full-square design, choose adaptive icon foreground/background carefully. Android adaptive icon foregrounds can be clipped by launchers, so prefer a foreground asset with safe padding when available.

## Generator Commands

Run from the Flutter app root:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Do not manually edit generated icon files after running the packages unless there is a documented platform-specific reason.

## Platform Display Names

Update only visible display names by default.

Android:

```xml
<application
    android:label="Brand Name"
    android:icon="@mipmap/ic_launcher">
```

iOS:

```xml
<key>CFBundleDisplayName</key>
<string>Brand Name</string>
```

Do not rename these unless explicitly requested:
- Flutter package name in `pubspec.yaml`.
- Android package/application ID.
- iOS bundle identifier.
- Dart class names that are architecture or compatibility identifiers.
- Route names, deep links, API paths, endpoint names, local storage keys, or shared preference keys.

When compatibility identifiers contain the old brand, leave them in place and update only visible strings.

## In-App Branding Rules

- Put reusable brand/logo widgets in `lib/core/widgets/`; one public widget per file with a snake_case filename.
- Prefer `Image.asset` for bundled raster app icons and logos.
- Declare every displayed asset in `pubspec.yaml`.
- Use theme colors through `ThemeData`, the existing theme layer, or `Theme.of(context)` rather than scattering hardcoded colors.
- Keep login phone/email fields autofocus-enabled.
- Keep OTP fields autofocus-enabled and preserve behavior that preloads returned debug/test OTP values.
- Preserve existing BLoC, repository, navigation, and auth-flow behavior unless the task explicitly asks to change it.
- Keep mobile auth screens form-focused; do not force desktop/admin two-panel layouts on narrow mobile screens.
- Use `toastification` or the app's existing toast helper for user-facing messages; do not introduce snackbars.

## Native Splash Notes

- Native splash is only the launch handoff before Flutter draws the first frame. Keep it simple and fast.
- In-app splash screens can show richer state, minimum duration, auth checks, and navigation.
- Avoid duplicating long animations in native splash and in-app splash.
- If the app already has an in-app `SplashScreen`, keep the native splash visually aligned but do not move auth checks into platform files.

## Verification

After implementation, run:

```bash
flutter analyze
```

Also verify:
- `pubspec.yaml` declares every displayed brand asset.
- `dart run flutter_launcher_icons` completed successfully.
- `dart run flutter_native_splash:create` completed successfully.
- Android generated icons exist under `android/app/src/main/res/mipmap-*` and any generated adaptive icon resources exist under `android/app/src/main/res/mipmap-anydpi-v26/`.
- iOS generated icons exist under `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.
- Native splash files changed under Android and iOS as expected.
- Android display label is correct in `AndroidManifest.xml`.
- iOS display name is correct in `Info.plist`.
- `lib/`, `android/`, `ios/`, and `pubspec.yaml` do not contain old visible brand strings except compatibility identifiers intentionally left unchanged.

Do not run `flutter build`, `flutter run`, or store release commands as routine verification unless the user explicitly asks or the change affects build/release configuration beyond generated branding assets.
