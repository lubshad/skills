---
name: frontend-auth-entry-ui
description: Use when designing or changing login, signup, OTP, or account-access UI.
---

# Auth Entry UI

Wide desktop/tablet/admin auth uses two sections: left brand/logo/positioning/visual with optional feature/status highlights; right constrained readable form, primary submit, validation/pending states, and correct input behavior. Narrow mobile reduces/hides branding for a single form-focused flow. Keep first actionable input reachable without delay/scroll.

## OTP and focus

Autofocus login phone/email and configured N-digit OTP (default 4), opening the keyboard. When an OTP API returns `otp`, prefill verification without frontend environment guards: backend controls whether test OTP is returned.

Debug phone auth uses configured country/phone defaults; otherwise `+91 9744714697`. Keep defaults in config, not widgets.

## Companions and verification

Use `frontend-forms.md` for validation/submission/autofill, `frontend-country-code-picker.md` for phone country UI, `frontend-device-layout.md` for responsive behavior, then relevant platform auth/routing/performance adapters.

Web credentials follow `frontend-api-client.md`: new token auth uses same-origin BFF/server-controlled or authenticated-encrypted HttpOnly credentials; login/logout CSRF and server authorization are separate from form presentation.

## Verification

Check wide/narrow layout, autofocus/keyboard submission, pending/recoverable errors, no browser-readable API secrets, and server-validated protected identity/access.
