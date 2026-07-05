---
name: flutter-linting
description: Use for all Flutter code changes to follow linting, formatting, analysis, and code-quality rules.
---

Follow these linting rules strictly when working on Flutter code.

## Rules

- **No deprecated APIs.** Never use deprecated methods, classes, or parameters. Find and use the replacement immediately.
- **No unused imports.** Remove every unused import before committing. Run `dart fix --apply` if needed.
- **Zero warnings.** Fix all lint warnings and errors — do not suppress them with `// ignore` unless there is a documented reason.
- **Logging.** Never use `print()` or `debugPrint()` directly in business logic or UI. Always use the project's dedicated logger, such as `AppLogger` (typically located at `core/utils/app_logger.dart`), to ensure logs are consistently formatted and properly stripped or routed in release builds.
- **Prefer const.** Use `const` constructors wherever possible for widgets and values.
- **Trailing commas.** Always add trailing commas after the last parameter in multi-line function calls and widget trees — this keeps diffs clean and auto-formatting consistent.
- **Analysis options.** Respect the project's `analysis_options.yaml`. Do not weaken lint rules.

## Verification

- For ordinary Flutter code and UI changes, run `flutter analyze` as the default verification step.
- Do not run `flutter build`, `flutter run`, or start a local app server just to check for errors unless the user explicitly asks for it.
- Only build or run when the task changes build/deploy/run configuration, platform entry points, generated assets, or a runtime behavior that cannot be reasonably verified by analysis alone.
