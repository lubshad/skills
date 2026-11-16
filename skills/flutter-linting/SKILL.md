---
name: flutter-linting
description: Use when changing Flutter code.
---

# Flutter Quality

- Replace deprecated APIs and remove unused imports (`dart fix --apply` when needed).
- Resolve all warnings/errors; suppress only with a documented reason. Preserve `analysis_options.yaml` strictness.
- Use the dedicated logger, such as `AppLogger` in `core/utils/app_logger.dart`, not business/UI `print()` or `debugPrint()`. Preserve release log handling.
- Prefer `const`; use trailing commas in multiline calls/widget trees.

## Verification

Default to `flutter analyze`. Do not build, run, or start an app server merely to find errors unless requested. Build/run only for changed build/deploy/run config, entrypoints, generated assets, or behavior analysis cannot reasonably verify.
