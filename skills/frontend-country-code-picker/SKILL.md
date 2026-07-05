---
name: frontend-country-code-picker
description: Use when designing or implementing country code picker visuals, search, selection, and interaction behavior.
---

# Country Code Picker Standard

Use this skill for country code pickers/selectors in any frontend platform.

## Core Rules

- The primary trigger displays only the flag and dial code, for example `+966`.
- Do not show ISO codes such as `SA`, `IN`, or `US` in the collapsed trigger.
- Country names and ISO codes may appear in expanded search results if needed for clarity.
- Keep flag, dial code, and phone number input aligned horizontally with consistent vertical centering.
- Default selection should dynamically fall back to the backend's configuration (e.g., `otp_default_region` from `flutter_utils` API) rather than being hardcoded in the frontend. If no dynamic configuration is available, follow app-specific default constraints.

## Anti-Patterns

- `Saudi Arabia (+966)` inside the collapsed trigger.
- `SA (+966)` in the collapsed trigger.
- Missing flag/icon in the trigger.
- Trigger width changing as the selected country changes.

## Platform Adapters

- Next.js implementation details live in `nextjs-forms.md` or the feature's established auth/form components.
- Flutter implementation details live in `flutter-forms.md` or the feature's established form widgets.
