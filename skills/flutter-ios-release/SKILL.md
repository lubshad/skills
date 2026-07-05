---
name: flutter-ios-release
description: Use when creating, updating, or explaining Flutter iOS release, App Store, TestFlight, Xcode Organizer, Xcode Cloud ci_post_clone.sh, multiple Dart entrypoints, CocoaPods, or Swift Package Manager setup.
---

# Flutter iOS Release

Use this skill when configuring or explaining deployments for Flutter iOS applications. This covers both local/manual App Store releases (via Xcode Organizer) and cloud/TestFlight automation (via Xcode Cloud workflows).

## Read With

- `flutter-linting.md` for pre-release verification rules.
- `flutter-utilities.md` for general app environment rules.
- `github-actions-deployment.md` only if comparing CI systems.

## Entrypoints

When a Flutter app has multiple entrypoints (e.g., `main_dev.dart`, `main_prod.dart`), you must tell Xcode which target to use before it archives the app.

- Use `-t lib/main_prod.dart` for production.
- Use `-t lib/main_dev.dart` only when explicitly building for development.

## 1. Xcode Cloud (`ci_post_clone.sh`)

When using Xcode Cloud for TestFlight or automated App Store releases:

- **Responsibility Check**: The `ci_post_clone.sh` script is only responsible for preparing Flutter dependencies, generating iOS configuration, and installing iOS-specific dependencies.
- **No Full Builds**: Do not run a full `flutter build ios` (without `--config-only`) inside the post-clone script. Let Xcode Cloud handle the actual archiving and signing.
- **Target Configuration**: Use `--config-only` to set the entrypoint target for Xcode:
  ```sh
  flutter build ios \
    --release \
    --config-only \
    --no-codesign \
    -t lib/main_prod.dart
  ```

## 2. Local App Store Release (`appstorerelease.sh`)

When running a manual/local build for App Store Connect:

- **Release Script**: Use a top-level `appstorerelease.sh` script to orchestrate the build.
- **Build Output**: Run `flutter build ipa --release -t lib/main_prod.dart`.
- **Xcode Handling**: Let Xcode Organizer handle the final validation, signing checks, and upload to App Store Connect. Do not use Fastlane for iOS unless explicitly required.
- **Automation**: Open Xcode Organizer automatically after build using `open -a Xcode build/ios/archive/Runner.xcarchive`.

## App Store Export Compliance

If the app does not use non-exempt encryption, ensure `ios/Runner/Info.plist` contains the following declaration to skip the export compliance warning during App Store Connect submission:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

This should be configured directly in `Info.plist` during deployment setup.

## CocoaPods vs Swift Package Manager (SPM)

Modern Flutter apps often use Swift Package Manager (SPM).
- **If `ios/Podfile` exists**: Run `pod install --repo-update`.
- **If `ios/Podfile` does NOT exist**: Do not install CocoaPods or run `pod install`. Rely on SPM (look for `FlutterGeneratedPluginSwiftPackage`).

## Reference Files

You can find generic templates in the `reference/` directory of this skill:
- `reference/ci_post_clone.sh`
- `reference/appstorerelease.sh`
