---
name: flutter-deploy
description: Use when configuring or executing Flutter branch promotion or version-increment helpers.
---

# Flutter Promotion

Root executable `deploy` and `version_increment.sh` use Bash/`set -euo pipefail`. Keep branch promotion distinct from build/sync `deploy.sh`. Read `github-actions-deployment.md` for CI implementation; promotion is a real deployment trigger, not routine verification.

## Guarded promotion

Require documented source (`main` by default), clean worktree, no detached/deployment/backup source, recognized arguments, and no behind/diverged source. Fetch/prune before release-ref checks. Commit only release-owned files (never `git add .`), push source first, back up the selected remote target, then replace with lease protection—not unrestricted force. Branch protection failures need policy repair, not weaker pushes.

Production-only apps retain default `production`/`production-backup`, initial-release handling, and bump-mode arguments. New target interfaces require explicit migration approval.

**Xealth Admin/Employee:** `./deploy` → `development`/`development-backup`; `--prod` → `production`/`production-backup`. Preserve independent major/minor/patch/build and `--message`; default patch. Require target existence before changing versions; initialization needs separate approval. Commit only the version file, push/fetch, capture target/backup OIDs, and use explicit `--force-with-lease=<ref>:<oid>`. Development backup must never receive production.

Development uses `main_dev.dart`; production `main_prod.dart`. Admin web maps to `backend-dev.xealth.ca`/`adminpanel-dev.xealth.ca` and also runs Android `internaltest`; retain production Android/Windows. Employee internal lane uploads the same package/signing to Play `internal`; production retains `azhar` merge-back. Both tracks share concurrency and globally increasing upload version codes. No `internaltest` branch/flag. Both apps trigger branch-matched Xcode Cloud (`flutter-ios-release.md`), not iOS Fastlane/GitHub builds. Examples: `flutter_apps/xealth_admin/deploy`, `flutter_apps/xealth_employee/deploy`. Other apps retain their release interfaces.

## Versions

Parse one exact `version: x.y.z+n` in app `pubspec.yaml`; support noninteractive major/minor/patch/build, default patch, and increment build in every mode. `--dry-run` changes nothing. Use portable macOS/Linux `sed -i.bak`; malformed/missing version fails clearly. Templates: `reference/deploy`, `reference/version_increment.sh`; examples: `./deploy`, `./deploy build`, `./deploy patch --message "chore: production release"`.

Before iOS promotion compare approved App Store marketing/build versions: closed/approved trains need higher `x.y.z`, not only `n` (ITMS-90186/90062). If already manually bumped, avoid a second marketing bump; use build mode only with an open new train or coordinate the version change.

## Authorized execution

For requested commit/push-main/development deployment: review/preserve unrelated work, commit scoped fixes, push main, then existing `./deploy` without `--prod`; let the helper own its bump/release commit. Check intended commit on source/target, previous target in backup, clean worktree, and unchanged production refs.

Verify every triggered pipeline independently: Xealth Cloud archive/TestFlight, Android internal, and Admin web artifacts/live behavior. Wait for terminal results when confirmation is requested; report version, commit, Apple build/distribution, GitHub links/results. Diagnose new blockers from logs, fix narrowly, and redeploy through the helper—not silent success or production changes.

## Verification

In disposable remotes test targets/backups, version flags, dirty/non-main guards, missing targets before version edits, and production merge-back. Real release commands are not test commands. Run `bash -n deploy version_increment.sh`, `./version_increment.sh --dry-run`, and `./deploy --help`; check executable modes/remotes/branches and a production listener workflow. Execute only explicitly requested releases.
