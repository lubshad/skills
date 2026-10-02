---
name: flutter-android-release
description: Use when creating, updating, or explaining Flutter Android release, Play Store, Fastlane, appbundle builds, playstorerelease.sh, signing keystores, GitHub Actions, or multiple Dart entrypoints.
---

# Flutter Android Release & GitHub Actions

Use this skill when implementing automated Play Store deployments for Flutter Android applications, particularly via GitHub Actions CI/CD workflows and Fastlane.

## Read With

- `flutter-utilities.md` for general app environment rules.
- `flutter-linting.md` for pre-release verification rules.
- `github-actions-deployment.md` for general CI/CD deployment logic.

## Entrypoints

- For explicitly requested development/internal testing releases, build `-t lib/main_dev.dart` and use Fastlane's `internal` track; production must remain on `main_prod.dart` and `production`.
- Xealth Employee's `./deploy` promotes `development`/`development-backup`; `./deploy --prod` promotes `production`/`production-backup`. `playstorerelease.sh development` selects Fastlane lane `internaltest` (Play track `internal`); no argument retains production behavior.
- Xealth Admin also has an Android development workflow on `development` invoking `internaltest` with `main_dev.dart`, alongside its development web deploy. It reuses the existing Play secret `XEALTH_ADMIN_PLAY_CREDENTIALS_JSON` and signing identity, shares concurrency with Android production, and preserves `production` and legacy `release` script/lane behavior. Neither Xealth app needs an `internaltest` branch or deploy flag.
- When both tracks use the same Play package/signing identity, use the same concurrency group for both workflows and ensure each uploaded version code exceeds all prior uploads. Internal testing is not a separate installed app; confirm testers understand it uses the development backend.
- Reconstruct signing and service-account files from secrets for both workflows, with normalized CI-relative keystore paths and cleanup after failure. Do not print credentials. Existing tracked credentials require separately coordinated rotation/history cleanup; ignore rules alone do not remove them.
- Xealth Employee secrets: `XEALTH_EMPLOYEE_ANDROID_KEYSTORE_BASE64`, `XEALTH_EMPLOYEE_ANDROID_KEY_PROPERTIES`, and `XEALTH_EMPLOYEE_PLAY_CREDENTIALS_JSON`. Its development workflow uses a guarded `development` ref and environment; production behavior and application ID stay unchanged.

When a Flutter app has multiple entrypoints (e.g., `main_dev.dart`, `main_prod.dart`), specify the production target when building the app bundle:
- Use `-t lib/main_prod.dart` for the production Play Store release.

## Core Conventions

- **Release Script**: Always use a top-level `playstorerelease.sh` script to orchestrate the build and Fastlane upload.
- **Build Output**: Use App Bundles (`.aab`) instead of APKs for Play Store releases.
- **Fastlane Setup**: Fastlane configuration must live inside the `android/fastlane/` directory.
- **GitHub Actions Workflow**: Place CI/CD workflows under `.github/workflows/` (relative to the Flutter app's root).

## The Release Script (`playstorerelease.sh`)

- Must contain `#!/bin/bash` and `set -e`.
- Should run `flutter clean`, `flutter pub get`, and `flutter build appbundle --release -t lib/main_prod.dart`.
- Must `cd android` before running `fastlane release`.

## Fastlane Configuration

### `Fastfile`
- The default lane should be called `release`.
- Use the `upload_to_play_store` action.
- The `aab` path is typically `../build/app/outputs/bundle/release/app-release.aab` because Fastlane runs from inside the `android` directory.
- Always set `skip_upload_screenshots: true` unless UI tests are explicitly generating and uploading them.

### `Appfile`
- Must point `json_key_file` to the local credentials JSON (e.g., `fastlane/playstore-credentials.json`).
- Define the `package_name`.

## GitHub Actions CI/CD Workflow

When automating this deployment via GitHub Actions:
- Trigger the workflow on push to the `production` branch.
- Use `actions/checkout@v4`.
- Set up Java 17 (`actions/setup-java@v4` with Zulu distribution).
- Set up Flutter stable (`subosito/flutter-action@v2`).
- Set up Ruby 3.2 (`ruby/setup-ruby@v1`) for Fastlane.
- **Inject Secrets**: Reconstruct the Android signing keystore, `key.properties`, and the Play Store service account JSON (`playstore-credentials.json`) from GitHub Secrets before running the build step.
- Run `playstorerelease.sh`.

## Security Warning
- **Never commit** signing keys, keystores, or service account credentials.
- Your `.gitignore` MUST include:
  - `android/fastlane/playstore-credentials.json`
  - `android/key.properties`
  - `android/app/*.jks` (e.g., `upload-keystore.jks`)
- Use GitHub Secrets (stored as base64 or raw text) to inject these files dynamically during the CI run.

## Reference Files
You can find generic templates in the `reference/` directory of this skill:
- `reference/playstorerelease.sh`
- `reference/Fastfile`
- `reference/Appfile`
- `reference/android_production_release.yml`
