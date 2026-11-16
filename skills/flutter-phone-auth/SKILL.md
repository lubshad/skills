---
name: flutter-phone-auth
description: Use when implementing Flutter Utils mobile phone login, OTP verification, or registration.
---

# Flutter Phone Auth

**OTP only:** no login/signup password fields. Use `flutter_utils.api.auth.send_mobile_login_otp`, `verify_mobile_login_otp`, `send_mobile_signup_otp`, `verify_mobile_signup_otp`, or the newer generic `send_otp`/`verify_otp` contracts.

Fetch `get_otp_auth_settings` at startup/splash for dynamic `otp_length`, `otp_resend_cooldown_seconds`, and `otp_default_region`. Country picker defaults to that region; concatenate selected dial code with raw phone input for APIs. Disable resend through the configured local cooldown timer.

## Flow

1. Login sends the concatenated mobile number. A 417 containing `No active account found` becomes a specific BLoC/ViewModel state (such as `AuthAccountNotFound`), not a generic error; navigate to signup with optional `initialCountryCode`/`initialMobile` to prefill.
2. Signup collects full name, email, and country-prefixed phone, sends signup OTP, then opens verification.
3. Verify configured N-digit OTP (default 4). UI validates dynamic length; repositories check only `.isEmpty`, never a hardcoded length.
4. Securely persist returned `api_key`/`api_secret` and optional user data through the app storage helper (for example `SharedPrefsHelper`), mark global auth authenticated, and navigate Home/Dashboard.

## Verification

Check dynamic settings, concatenation, cooldown, account-not-found redirect/prefill, OTP validation ownership, credential persistence, and authenticated navigation.
