---
name: flutter-phone-auth
description: Use when implementing or fixing mobile phone authentication, OTP login, or registration flows powered by flutter_utils.
---

Follow these instructions strictly when implementing phone authentication in a Flutter app using the `flutter_utils` Frappe app.

## General Principles

- **Passwordless Flow:** The entire authentication flow relies purely on OTP verification. Do not add `password` or `confirm_password` fields to any Login or Signup UI.
- **Unified Endpoints:** The backend uses `flutter_utils.api.auth.send_mobile_login_otp`, `verify_mobile_login_otp`, `send_mobile_signup_otp`, and `verify_mobile_signup_otp` (or the newer generic `send_otp`/`verify_otp` endpoints).

## Front-end UI Requirements

- **Dynamic Configuration:** App must fetch global OTP settings via `get_otp_auth_settings` on startup (or splash screen) to obtain `otp_length`, `otp_resend_cooldown_seconds`, and `otp_default_region`.
- **Country Code Picker:** The phone number input must include a visual country code picker (e.g., using the `country_code_picker` package). The `initialSelection` must default to the backend's `otp_default_region` (e.g., `IN` or `GB`).
- **Concatenation:** Always concatenate the selected dial code (e.g., `+44`) and the user's raw phone number input before sending it to the API.
- **Resend Cooldown:** The OTP screen must implement a local timer using `otp_resend_cooldown_seconds`. Disable the "Resend OTP" button while the timer is active to respect the backend's rate limiting.

## Login Flow & Unregistered Users

1. **Send OTP:** Call the login OTP API with the concatenated mobile number.
2. **Error Handling (417):** If the backend returns a `417` status code with an error message containing "No active account found", **do not** show a generic error to the user.
3. **Redirection:** Catch this specific error in the BLoC/ViewModel, emit a specific state (e.g., `AuthAccountNotFound`), and automatically navigate the user to the Signup/Registration screen.
4. **Auto-loading:** The Signup screen must accept optional arguments for `initialCountryCode` and `initialMobile` so that the user's phone number is pre-filled automatically when they are redirected from a failed login attempt.

## Signup / Registration Flow

1. **Collect Data:** On the Signup screen, collect the user's Full Name, Email Address, and Phone Number (with the country code picker).
2. **Send OTP:** Call the signup OTP API with the collected details.
3. **Navigate to Verification:** Upon a successful response, navigate the user to the OTP Verification screen.

## OTP Verification & Session Storage

1. **Verify OTP:** Call the verification API with the concatenated mobile number and the configured N-digit OTP (defaults to 4 digits) entered by the user. Note: Do not hardcode OTP length checks (e.g., `if (otp.length != 6)`) in the Repository layer. Perform exact length checks in the UI layer using the dynamic settings, and use simple `.isEmpty` checks in the repository.
2. **Handle Success:** If verification is successful, the backend will return an authentication payload containing `api_key` and `api_secret`.
3. **Save Token:** Securely save the `api_key` and `api_secret` (and optionally user details) to local storage (e.g., using `SharedPrefsHelper`).
4. **Navigate to Home:** Update the global authentication state to authenticated and navigate the user to the main Home/Dashboard screen.
