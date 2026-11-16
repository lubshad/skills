---
name: frontend-country-code-picker
description: Use when designing or implementing country code picker visuals, search, selection, and interaction behavior.
---

# Country Code Picker Standard

## Core Rules

- The fixed-width collapsed trigger shows only flag and dial code (`+966`), not country names or ISO codes. Expanded results may include both for clarity.
- Keep flag, dial code, and phone number input aligned horizontally with consistent vertical centering.
- Default selection should dynamically fall back to the backend's configuration (e.g., `otp_default_region` from `flutter_utils` API) rather than being hardcoded in the frontend. If no dynamic configuration is available, follow app-specific default constraints.

## Platform Adapters

- Next.js implementation details live in `nextjs-forms.md` or the feature's established auth/form components.
- Flutter implementation details live in `flutter-forms.md` or the feature's established form widgets.
