---
name: flutter-theming
description: Use when changing Flutter themes, colors, typography, notifications, local fonts, or animations.
---

# Flutter Theming

Read `frontend-design-consistency.md` before visual changes and `frontend-device-layout.md` for device intent. Inspect shell, peer screens, theme, and shared widgets; match composition, not colors alone.

## Theme and motion

Use bundled fonts declared in `pubspec.yaml`, not Google Fonts. Define colors/type/spacing in `ThemeData` or the existing theme layer; read through `Theme.of(context)`/app constants instead of feature-local hardcoding. Reuse core widgets. Support existing light/dark themes and surface hierarchy; styling one screen does not authorize global backgrounds/restyling.

Forms use shared input tokens: darker outline borders and subtle fill. Use `flutter_animate` for useful entry/transitions/loading micro-interactions without harming scanning or over-animating layout.

## Messages

Use the existing toast helper, then `toastification` if needed—not `SnackBar`, `showSnackBar`, or `ScaffoldMessenger` messages. Applies to saves, publishing, auth, validation, and async errors too; preserve required inline field errors.

Masar Admin: `ToastHelper.success/error/info` in `lib/core/utils/toast_helper.dart`; mobile: `AppToast` in `lib/core/utils/app_toast.dart`. Helpers must support multiline/large text and success/error/warning/info types.

## Verification

Search changed files for snackbar calls. Check correctly typed feedback emitted once from screen-level listeners. Run `dart format` and targeted Flutter analysis.
