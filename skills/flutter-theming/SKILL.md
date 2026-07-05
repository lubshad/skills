---
name: flutter-theming
description: Use when changing Flutter ThemeData, Theme.of(context), brand colors, typography, notifications, local fonts, or animations.
---

Follow these Flutter theming implementation rules strictly. Visual behavior and device intent live in `frontend-device-layout.md` and other `frontend-*` UI skills.

## Fonts

- Never use Google Fonts. Use only bundled/local font assets declared in `pubspec.yaml`.

## Notifications

- Never use Snackbars for user-facing messages. Use the `toastification` package or the app's toast helper.
- Toast helpers must support multi-line and larger messages.
- Use appropriate toast types: success, error, warning, info.

## Animations

- Use `flutter_animate` for transitions and micro-interactions.
- Apply animations to enhance UX, such as list item entry, page transitions, and loading states.
- Do not over-animate or animate layout in ways that harms scanability.

## Theme Usage

- Define colors, text styles, and spacing in `ThemeData` or the app theme layer.
- Reference theme values via `Theme.of(context)` or established app theme constants.
- Do not hardcode colors or font sizes in feature widget code when theme values exist.
- Support light/dark themes where the app supports them.
- In this app, keep detail/list surfaces on white backgrounds by using `scaffoldBackgroundColor`/`canvasColor` set to white in the app theme.
- For form controls, prefer shared input tokens rather than per-screen overrides: darker outline borders for clearer field distinction and a subtle filled background for text inputs.
