---
name: flutter-deploy
description: Use when setting up a Flutter production-promotion script, version-increment script, or branch release workflow.
---

# Flutter Branch Promotion And Version Increment

Use this skill when a Flutter repository releases by promoting `main` to a
deployment branch such as `production`.

## Core Conventions

- Keep `deploy` and `version_increment.sh` in the Flutter repository root.
- `./deploy` currently targets `production` by default and supports no alternative release target. Existing arguments such as `build` and `patch` select version-bump modes, not branches.
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

Run these checks without triggering a release:

```sh
bash -n deploy version_increment.sh
./version_increment.sh --dry-run
./deploy --help
```

Confirm both files are executable and inspect the repository's actual remote and
branch names. Execute promotion only when the user explicitly requests a release.
