---
name: flutter-mobile-branding
description: Use when branding Flutter mobile icons, native launch screens, display names, in-app splash/auth, or theme identity.
---

# Flutter Mobile Branding

For admin web shells use `flutter-admin-branding.md`; release automation belongs to the Android/iOS release adapters only when that behavior changes.

## Confirm inputs, then generate

Inspect the app and use `question` for every missing input: visible name; tagline/description; icon path (default `assets/pngs/app_icon.png`); in-app splash and native-launch colors; primary/accent colors; typography (keep existing/system/custom); whether auth shows the tagline; and whether Android/iOS share the display name. Offer concise choices/custom answers. Do not guess. If the icon is absent, stop for a provided file or confirmed existing alternative; no generation without a valid source.

Read `frontend-auth-entry-ui.md` and applicable shared layout guidance before changing those surfaces. Apply `flutter-architecture.md`, `flutter-common-widgets.md` for logos, `flutter-theming.md`, and `flutter-linting.md`; use `flutter-utilities.md` for splash/auth/config/run behavior. Release changes need `flutter-android-release.md` or `flutter-ios-release.md`.

1. Identify app root/surfaces and validate the source asset, preferably square PNG ≥1024px.
2. Collect missing inputs; update asset declarations and generator config in `pubspec.yaml`.
3. Update visible Android/iOS names, native launch configuration, all entrypoint titles, in-app splash/auth/onboarding text, and theme/typography from confirmed inputs.
4. From app root run `flutter pub get`, `dart run flutter_launcher_icons`, and `dart run flutter_native_splash:create`.

## Generator contract

Use dev packages `flutter_launcher_icons: ^0.14.4` and `flutter_native_splash: ^2.4.4`, not hand-resized assets. Configure icons for Android/iOS with the real `image_path`, adaptive foreground/background, and `remove_alpha_ios: true`. Give adaptive foregrounds safe padding to avoid clipping.

Splash config needs chosen `color`, source `image`, Android/iOS enabled, and matching `android_12.color/image`. Declare the asset under `flutter.assets`. Generated files are not hand-edited without a documented platform reason.

Visible names: `android:label` in `android/app/src/main/AndroidManifest.xml`; `CFBundleDisplayName` in `ios/Runner/Info.plist`. Preserve package/application/bundle IDs, architectural class names, routes/deep links, APIs, endpoints, and storage/preference keys unless explicitly authorized. Old-brand compatibility identifiers may remain.

## Runtime identity

Shared logos belong in `lib/core/widgets/`, one public widget per snake_case file; use `Image.asset` for raster assets and shared theme values instead of scattered literals. Preserve BLoC/repositories/navigation/auth, phone/email/OTP autofocus, and returned test-OTP prefill. Narrow auth stays form-focused. Use shared toasts/`toastification`, not snackbars.

Native splash is a fast first-frame handoff; align it with the richer in-app splash without duplicate long animations. Keep auth checks/minimum-duration/navigation in Flutter, not platform files.

## Verification

Run `flutter analyze`. Confirm both generators succeeded, all assets are declared, and Android mipmap/adaptive resources, iOS `AppIcon.appiconset`, and native launch files changed as intended. Check manifest/plist display names and search `lib/`, `android/`, `ios/`, and `pubspec.yaml` for old visible strings, excluding retained identifiers. No routine build/run/store release unless requested or build/release config beyond generated branding requires it.
