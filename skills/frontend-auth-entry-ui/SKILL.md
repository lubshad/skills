---
name: frontend-auth-entry-ui
description: Use when designing or changing login, signup, OTP, authentication entry, and account access UI.
---

# Auth Entry UI Standard

Use this skill for login, signup, OTP, authentication entry, and account access screens on any frontend platform.

## Core Rule

Desktop, tablet-wide, and browser-hosted admin auth screens must use a two-section layout:
- **Left:** branding, product name/logo, relevant visual or background, short positioning copy, and optional feature/status highlights.
- **Right:** focused auth form, constrained readable width, visible primary submit action, validation/loading states, and platform-correct input behavior.

## Device Behavior

- Desktop and tablet-wide widths: keep branding and form side by side.
- Narrow mobile widths: collapse to a single form-focused screen; hide or reduce the branding panel.
- Do not force a two-column layout on narrow mobile screens.
- Keep the first actionable input visible without unnecessary waiting or scrolling.

## OTP Behavior

- When an OTP send/login API response includes an OTP value, load that OTP into the OTP verification field automatically instead of making the user or tester copy it manually.
- Do not add frontend environment checks around this behavior. The backend controls whether `otp` is returned, such as only in test mode.

## Input Focus & Keyboard

- Primary input fields on authentication screens MUST use autofocus (e.g., `autofocus: true` in Flutter).
- Specifically, the phone number or email entry field on the login screen, and the configured N-digit (default 4) pin field on the OTP verification screen must automatically focus when the screen is opened, bringing up the keyboard immediately for a seamless user experience.

## Debug Defaults

- For phone-based auth screens, debug mode should prefill the configured default country code and phone number when the product provides them.
- Use `+91 9744714697` as the standard debug default phone when no product-specific default is provided.
- Keep debug default phone values in app config, not hardcoded directly inside widgets.

## Related Skills

- `frontend-forms.md` for validation, input behavior, submit state, and dummy-data rules.
- `frontend-country-code-picker.md` for phone login country picker UI.
- `frontend-device-layout.md` for desktop/tablet/mobile behavior.
- Platform-specific auth, routing, and performance rules remain in `flutter-*` and `nextjs-*` skills.
