# Skill: flutter-goproduction

# Flutter Branch Promotion & Version Increment

Use this skill when setting up a Flutter application for production releases, specifically when the user asks for the "go production" script or release promotion workflow.

## Core Conventions

- **Responsibilities**: The `goproduction` script is responsible for bumping the app version, committing changes, backing up the remote production branch, and force-pushing the current branch (usually `main`) to `production`.
- **Version Increment**: It relies on an interactive `version_increment.sh` script to parse and update `pubspec.yaml` versions (Major, Minor, Patch, Build).
- **Execution**: Both scripts must be made executable (`chmod +x`).

## File Placement
When implementing this workflow for an app, copy the reference scripts to the root of the Flutter application directory:
- `<app_root>/goproduction`
- `<app_root>/version_increment.sh`

## CI/CD Integration
This script is designed to trigger automated workflows (like GitHub Actions or Xcode Cloud) by updating the `production` branch. Ensure the app has the appropriate CI/CD workflows listening to pushes on the `production` branch.
