---
name: flutter-android-release
description: Use when configuring or explaining Flutter Play Store releases, Fastlane, appbundles, Android signing, or release workflows.
---

# Flutter Android Release

Read `flutter-utilities.md`, `flutter-linting.md`, and `github-actions-deployment.md`. New Flutter Utils apps also need `flutter-app-release-gates.md` (startup/resume gates, tests, operator setup); uploading an unpublished release does not authorize forced updates.

## Build and upload

Root executable `playstorerelease.sh` uses `#!/bin/bash`, `set -e`, `flutter clean`, `flutter pub get`, and `flutter build appbundle --release -t lib/main_prod.dart`, then `cd android` and `fastlane release`. Play uploads use `.aab`, not APKs.

Keep Fastlane in `android/fastlane/`. `Fastfile` defaults to `release`, uses `upload_to_play_store`, typically `../build/app/outputs/bundle/release/app-release.aab`, and `skip_upload_screenshots: true` unless explicit UI-test uploads exist. `Appfile` declares package and local JSON key path (for example `fastlane/playstore-credentials.json`). Templates: `reference/playstorerelease.sh`, `reference/Fastfile`, `reference/Appfile`, `reference/android_production_release.yml`.

Production Actions runs on `production`: checkout v4, Java 17 Zulu/setup-java v4, stable Flutter/flutter-action v2, Ruby 3.2/setup-ruby v1, credential injection, release script.

## Environments

Explicit development/internal testing uses `main_dev.dart` and Play `internal`; production stays `main_prod.dart`/`production`. Same-package tracks share signing, workflow concurrency, and strictly increasing version codes across all uploads. Internal testing replaces the installed app and uses the development backend; tell testers.

Xealth Employee/Admin use `./deploy` → `development`/`development-backup`, `--prod` → `production`/`production-backup`. `playstorerelease.sh development` selects `internaltest` lane (track `internal`); no argument remains production. No `internaltest` branch/flag. Employee development uses guarded ref/environment; production app ID stays unchanged. Admin development Android coexists with web, preserves production and legacy `release` behavior, and reuses `XEALTH_ADMIN_PLAY_CREDENTIALS_JSON` and signing identity. Employee secrets: `XEALTH_EMPLOYEE_ANDROID_KEYSTORE_BASE64`, `XEALTH_EMPLOYEE_ANDROID_KEY_PROPERTIES`, `XEALTH_EMPLOYEE_PLAY_CREDENTIALS_JSON`.

## Signing policy

Default: inject keystore, `key.properties`, and service-account JSON from secrets; normalize CI-relative paths and clean up even on failure. Ignore `android/fastlane/playstore-credentials.json`, `android/key.properties`, and `android/app/*.jks`. Never print credentials. Tracked credentials need separately coordinated rotation/history cleanup; ignore rules do not remove them.

Only explicit user acceptance of exposure permits a documented repository-signing exception. Masar mobile (`flutter_apps/masar_mobile_app`) is authorized to track `android/key.properties` and `android/app/upload-keystore.jks`; only `PLAYSTORE_SERVICE_ACCOUNT_JSON` remains required for Android workflows. JSON stays ignored/injected. Warn that repository/history readers can see keystore/passwords. Preserve existing identity; no new/rotated key without approval and Play compatibility checks. Use `storeFile=upload-keystore.jks` relative to `android/app`; validate files and never delete tracked signing material in cleanup. Do not extend this exception to other apps.

## Verification

Check selected signing policy, workflow secret names, ignored JSON, and keystore/password/alias compatibility without printing secrets. Preserve unrelated work. After skill edits run both catalog validators.
