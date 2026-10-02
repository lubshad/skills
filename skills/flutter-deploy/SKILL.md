---
name: flutter-deploy
description: Use when setting up a Flutter production-promotion script, version-increment script, or branch release workflow.
---

# Flutter Branch Promotion And Version Increment

Use this skill when a Flutter repository releases by promoting `main` to a
deployment branch such as `production`.

## Core Conventions

### Explicit dual-environment contract

- Xealth Admin and Xealth Employee use `./deploy` for `development` with `development-backup`, and `./deploy --prod` for `production` with `production-backup`. Preserve `major|minor|patch|build` and `--message` arguments independently of target selection; default version bump remains `patch`.
- Require a clean worktree and the documented source branch (`main` for these apps). Reject detached HEAD, all deployment/backup source branches, unknown flags, and a behind/diverged source. Require the selected remote target before changing versions; initialization is a separate approved operation that can trigger a release.
- Commit only the version file, push the source, fetch, capture target and backup OIDs, then back up and promote using explicit `--force-with-lease=<ref>:<expected-oid>` guards. Never copy production into the development backup.
- Xealth Admin development deploys web using `main_dev.dart`, `backend-dev.xealth.ca`, and `adminpanel-dev.xealth.ca`, and also publishes Android to Play internal testing through Fastlane lane `internaltest`; retain production Android/Windows workflows.
- Xealth Employee development builds `main_dev.dart` and invokes Fastlane lane `internaltest` to upload to Google Play `internal` with the existing package/signing identity. Production builds `main_prod.dart` and retains its `azhar` merge-back. Both Play tracks share concurrency because they edit the same application; version codes must exceed all prior uploads. For both Xealth Flutter apps, internal testing runs on `development`, not a separate `internaltest` branch or deploy flag.
- Keep the branch helper `deploy` separate from an existing local build/sync utility `deploy.sh`.
- The production-only conventions and reference below remain for apps not explicitly migrated. Current dual-environment examples are `flutter_apps/xealth_admin/deploy` and `flutter_apps/xealth_employee/deploy`; do not silently change other apps' release interfaces.

- Keep `deploy` and `version_increment.sh` in the Flutter repository root.
- Existing production-only helpers target `production` by default. Existing arguments such as `build` and `patch` select version-bump modes, not branches. Explicitly migrated dual-environment apps follow the contract above instead.
- Planned target-selection interface: `./deploy` uses `production` with `production-backup`; `./deploy --internaltest` will use `internaltest` with `internaltest-backup`. Keep target selection separate from version-bump arguments such as `build` and `patch`.
- The `--internaltest` flag is not supported by current reference scripts. Implement it only when requested, with a matching workflow and target-specific safety guards; back up the selected target's previous ref and preserve the default production behavior.
- Start both scripts with `#!/bin/bash` and `set -euo pipefail`.
- Make both scripts executable.
- Require promotion from `main` unless the repository documents another source branch.
- Fetch and prune remote refs before checking or updating release branches.
- Refuse promotion when local `main` is behind or diverged from `origin/main`.
- Commit only release-owned files such as `pubspec.yaml`; never use `git add .`.
- Push the source branch before promoting it.
- Back up an existing remote `production` branch to `production-backup`.
- Handle the initial release when the remote `production` branch does not exist.
- Use `--force-with-lease`, not unrestricted `--force`, for branch replacement.
- Treat a successful push to `production` as a real deployment trigger.
- For iOS, an approved version or closed pre-release train cannot accept another build of the same marketing version. Before promoting an App Store release, compare the app's version with the latest approved version in App Store Connect and bump `x.y.z` higher (usually `patch`); a build-only bump does not resolve ITMS-90186 or ITMS-90062. Check the build number against existing uploads as well.
- If `pubspec.yaml` was already bumped manually for the upcoming iOS release, do not blindly bump its marketing version a second time during promotion. Use the explicit `build` mode only if the new version's train is still open, or coordinate the version change with the promotion script.

## Version Increment

The version helper must:

- Parse one exact `version: x.y.z+n` line from the app-local `pubspec.yaml`.
- Support non-interactive `major`, `minor`, `patch`, and `build` modes.
- Default to `patch`.
- Increment the build number for every mode.
- Support `--dry-run` without changing files.
- Work on macOS and Linux; use a portable temporary backup with `sed -i.bak`.
- Fail clearly when the version line is missing or malformed.

## Reference Files

Copy and adapt these files:

- `reference/deploy`
- `reference/version_increment.sh`

The reference promotion script accepts:

```sh
./deploy              # patch release by default
./deploy build
./deploy patch --message "chore: production release"
```

## CI/CD Coordination

- Ensure a CI/CD workflow listens for pushes to `production` before promoting.
- Use `github-actions-deployment.md` for GitHub Actions implementation details.
- Do not run `deploy` as routine verification because it commits, pushes,
  rewrites release refs, and may deploy production.
- If branch protection rejects lease-protected promotion, update the repository's
  release policy instead of weakening the script to unrestricted force pushes.

## Verification

- Test both targets and their backups in disposable local Git remotes, including version arguments, dirty/non-main guards, missing targets before version changes, and production-only merge-back. Do not run either real release command during verification.

Run these checks without triggering a release:

```sh
bash -n deploy version_increment.sh
./version_increment.sh --dry-run
./deploy --help
```

Confirm both files are executable and inspect the repository's actual remote and
branch names. Execute promotion only when the user explicitly requests a release.
