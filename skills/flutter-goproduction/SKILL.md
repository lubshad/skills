---
name: flutter-goproduction
description: Use when setting up a Flutter production-promotion script, version-increment script, or branch release workflow.
---

# Flutter Branch Promotion And Version Increment

Use this skill when a Flutter repository releases by promoting `main` to a
deployment branch such as `production`.

## Core Conventions

- Keep `goproduction` and `version_increment.sh` in the Flutter repository root.
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

- `reference/goproduction`
- `reference/version_increment.sh`

The reference promotion script accepts:

```sh
./goproduction              # patch release by default
./goproduction build
./goproduction patch --message "chore: production release"
```

## CI/CD Coordination

- Ensure a CI/CD workflow listens for pushes to `production` before promoting.
- Use `github-actions-deployment.md` for GitHub Actions implementation details.
- Do not run `goproduction` as routine verification because it commits, pushes,
  rewrites release refs, and may deploy production.
- If branch protection rejects lease-protected promotion, update the repository's
  release policy instead of weakening the script to unrestricted force pushes.

## Verification

Run these checks without triggering a release:

```sh
bash -n goproduction version_increment.sh
./version_increment.sh --dry-run
./goproduction --help
```

Confirm both files are executable and inspect the repository's actual remote and
branch names. Execute promotion only when the user explicitly requests a release.
