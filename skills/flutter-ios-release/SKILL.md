---
name: flutter-ios-release
description: Use when configuring or explaining Flutter App Store/TestFlight releases, Xcode Cloud, iOS post-clone scripts, CocoaPods, or SPM.
---

# Flutter iOS Release

**Preparation is not distribution.** Xcode Cloud archives/signs/uploads; post-clone prepares Flutter/dependencies with `--config-only --no-codesign`, never a full iOS build. Local releases use root `appstorerelease.sh`, `flutter build ipa`, and Xcode Organizer; no Fastlane unless requested.

Before changing release setup, read [the iOS runbook](IOS-RELEASE.md). It owns strict environment/branch matching, pinned SDK installation, CocoaPods/SPM paths, export compliance, failure triage, templates, and required checks. Preserve production-only apps unless migration is authorized.

## Critical boundaries

- Production targets `main_prod.dart`; development explicitly selects `main_dev.dart`. Xealth workflows require matching `XEALTH_APP_ENVIRONMENT`/`CI_BRANCH` and unique `CI_BUILD_NUMBER`.
- Pin/verify a released Flutter SHA and fetch its release tags; no moving-stable fallback or blind dependency upgrades.
- Closed/approved App Store trains need a higher marketing version; build-only increments do not fix ITMS-90186/90062.
- Legal agreements require the authorized Account Holder, never automated acceptance. User handles sign-in/2FA.
- New Flutter Utils release setup includes `flutter-app-release-gates.md`; publishing alone does not authorize a forced update.

## Verification

Follow runbook syntax/mode and isolated fake-command tests. Linux cannot prove archive/signing/distribution. After authorized promotion verify exact commit/environment, Archive and intended TestFlight post-action, then report build number and outcome—not Git-push success alone.
