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

### Development and production workflows

- For explicitly dual-environment apps such as Xealth Admin and Employee, configure separate Xcode Cloud workflows triggered only by `development` and `production` respectively. No additional `internaltest` branch or iOS Fastlane lane is needed.
- Set custom workflow variable `XEALTH_APP_ENVIRONMENT=development` or `production`. The post-clone script must require this variable and Xcode Cloud's `CI_BRANCH`, select `main_dev.dart`/`main_prod.dart`, and reject unknown or mismatched environments before installing/configuring anything. Accept plain branch names and normalize an optional `refs/heads/` prefix.
- Configure this variable in the existing production workflow before promoting script changes; missing values should fail safely, not silently choose production. Preserve existing production-only apps unless explicitly migrated; use `reference/ci_post_clone_dual_environment.sh` for the strict two-target contract.
- Add an iOS archive action and TestFlight internal-testing post-action with the intended tester group to the development workflow. Retain the existing production distribution process, bundle ID and signing configuration. Apple workflow settings live in Xcode/App Store Connect, not GitHub Actions YAML; report UI setup as pending unless actually configured.
- Keep archive/signing/upload responsibilities in Xcode Cloud. Post-clone scripts only prepare dependencies and generate Flutter iOS configuration with `--config-only --no-codesign`. Install CocoaPods only if `ios/Podfile` exists.
- Do not use `set -x` in credential-bearing build scripts. Keep script mode `100755` and avoid logging secret environment values.
- Both workflows upload to the same App Store Connect app. Coordinate unique build numbers and inspect resolved `CFBundleVersion`; do not assume Xcode Cloud uses `pubspec.yaml`'s build number. Development TestFlight replaces the same installed app identity; it is not a separate app.

When using Xcode Cloud for TestFlight or automated App Store releases:

- **Executable Script**: Commit `ios/ci_scripts/ci_post_clone.sh` with executable mode `100755`; run `git add --chmod=+x ios/ci_scripts/ci_post_clone.sh` before committing it.
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

App Store version validation is separate from export-compliance declarations: if App Store Connect reports ITMS-90186 (closed pre-release train) or ITMS-90062 (version not higher than the previously approved version), increment the Flutter `pubspec.yaml` marketing version (`x.y.z` in `version: x.y.z+n`) above the latest approved version and use a valid new build number. Increasing only `n` cannot reopen a closed or approved version. Confirm the archived app's resolved `CFBundleShortVersionString` and `CFBundleVersion` before upload, particularly when Xcode Cloud reports a build number different from `pubspec.yaml`.

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
- `reference/ci_post_clone_dual_environment.sh`
- `reference/appstorerelease.sh`

## Verification

- Run `sh -n` on modified post-clone scripts and verify executable mode.
- Use isolated fake Flutter/git/pod commands to test both environments, branch-prefix normalization, missing/unknown variables, branch mismatches, absent entrypoints and conditional CocoaPods/SPM paths without network calls or signing/uploads.
- Verify only configuration builds are invoked, without full iOS builds in post-clone.
- Actual archives, signing and TestFlight distribution require macOS/Xcode Cloud; Linux checks cannot validate those steps. Confirm workflow triggers, custom variables, archive actions, tester groups and build-number settings in Apple's UI before release.
