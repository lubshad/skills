# Flutter iOS Release

Use this skill when configuring or explaining deployments for Flutter iOS applications. This covers both local/manual App Store releases (via Xcode Organizer) and cloud/TestFlight automation (via Xcode Cloud workflows).

## Read With

- `flutter-linting.md` for pre-release verification rules.
- `flutter-utilities.md` for general app environment rules.
- `flutter-deploy.md` when committing fixes and promoting main to development or production.
- `github-actions-deployment.md` only if comparing CI systems.
- `flutter-app-release-gates.md` when setting up releases for a new app backed
  by `flutter_utils`, including GitHub or Xcode Cloud setup. Include client gates,
  startup/resume checks, tests, and operator configuration; TestFlight upload or
  App Store submission alone does not justify enabling a forced update.

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
- Require `CI_BUILD_NUMBER` and pass it via `--build-number` for these dual-environment apps. Keep `Info.plist` linked to `FLUTTER_BUILD_NUMBER` and `FLUTTER_BUILD_NAME`, and verify the archive's resolved values.
- Workflow names are labels, not environment selectors: an existing `Testflight` workflow can serve development and `Production` can serve production. Inspect all existing workflows before changing or duplicating one. Match the exact branch trigger to its environment variable; do not use prefix triggers that include backup branches.
- Manage workflows through App Store Connect's Xcode Cloud browser UI (Playwright when requested) or Xcode on macOS. Browser management is possible from Linux; local archives are not. Preserve the actual configured tester group rather than replacing it with a group name copied from documentation. Ask the user to complete sign-in/2FA directly in the browser.

### Reproducible Flutter SDK installation

- Pin a verified Flutter release revision. For a shallow SHA checkout, fetch **release tags** too (`git fetch --depth 1 --tags origin "$FLUTTER_REVISION"`); a SHA-only fetch can make Flutter report `0.0.0-unknown` and cause otherwise valid pub dependencies to fail their Flutter SDK constraints.
- Refresh cached checkouts to the pin, prepend the pinned SDK's `bin` to PATH, and check `flutter --version --machine` reports a valid release before `flutter pub get`. Fail clearly instead of silently falling back to moving `stable`.
- Verify the intended release tag points to the pinned SHA before changing the pin. Keep dependency upgrades targeted; don't broadly upgrade packages just to repair an SDK installation error.

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

### Xcode Cloud failure triage

- Inspect the newest build's commit, branch, action issues, and expanded post-clone log. A missing `FlutterGeneratedPluginSwiftPackage` can be a downstream effect of post-clone stopping early; fix the first error rather than committing generated ephemeral packages.
- If `Package.resolved` is out of date and Cloud disables automatic resolution, allow resolution in the disposable Cloud runner before the config-only Flutter invocation:
  ```sh
  defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO
  defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
  ```
  Flutter regenerates its plugin package and may resolve packages even with `--config-only`. Preserve checked-in pins as inputs; don't delete lockfiles or patch cached SDK/plugin sources blindly. Resolve the current graph during setup so Cloud can archive it afterward. This may update native pins in the build checkout; inspect the resolved graph when diagnosing version drift.
- Firebase plugins can impose different **exact** native SDK versions even when pub resolves successfully. Inspect installed iOS `Package.swift` manifests and Firebase Core's SDK version; align only the conflicting plugin versions in `pubspec.lock` (and constraints if necessary). In the verified Employee repair, Auth 6.7.0, Core 4.15.0, and Messaging 16.7.0 all require native Firebase 12.19.0. These are a historical compatibility example, not permanent upgrade targets for every app.
- An error at **Prepare Build for App Store Connect** stating that an in-effect agreement is unsigned/expired is an account/legal blocker, not a compilation defect. Check App Store Connect → Business and, if necessary, the Developer account's agreement status. The authorized Account Holder must review/accept legal agreements; never accept them as part of an automated repair. Verify current status rather than assuming an old failed build still reflects today's agreement state.

## Reference Files

You can find generic templates in the `reference/` directory of this skill:
- `reference/ci_post_clone.sh`
- `reference/ci_post_clone_dual_environment.sh`
- `reference/appstorerelease.sh`

## Verification

- Run `sh -n` on modified post-clone scripts and verify executable mode.
- Use isolated fake Flutter/git/pod/defaults commands to test both environments, branch-prefix normalization, missing/unknown variables, branch mismatches, absent entrypoints, cached/fresh SDKs, tag fetching, invalid SDK versions, failed fetches and conditional CocoaPods/SPM paths without network calls or signing/uploads.
- Verify only configuration builds are invoked, without full iOS builds in post-clone.
- Actual archives, signing and TestFlight distribution require macOS/Xcode Cloud; Linux checks cannot validate those steps. Confirm workflow triggers, custom variables, archive actions, tester groups and build-number settings in Apple's UI before release.
- After an authorized promotion, confirm the new Cloud build references the promoted commit and matching environment. Wait for both **Archive – iOS** and the intended distribution post-action to succeed; a successful Git push or archive alone is not proof of TestFlight delivery. Report build number, commit, environment, and any remaining warnings or test failures. Rebuilding an old commit does not use unpushed fixes.
