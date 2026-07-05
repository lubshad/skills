---
name: flutter-utilities
description: Use when changing Flutter auth flow plumbing, splash screens, webviews, HTML handling, environment config, or utilities.
---

Follow these utility rules strictly when working on Flutter code.

## Authentication & Debug

- **Debug credentials.** On login and signup screens, automatically load credentials from app config when running in `kDebugMode`. Include a "Fill" button to populate fields instantly.
- **Sensitive data.** Load API keys, secrets, and base URLs from `.env` files — never hardcode them.
- **Frappe auth.** When the target Frappe site has `flutter_utils` installed, login screens must use `flutter_utils.api.auth.login` for username/password authentication and persist only the returned `api_key` / `api_secret` token pair locally. Do not use dummy local auth or Frappe's built-in login endpoint unless explicitly required.
- **Auth state.** Splash/auth checks should validate stored `flutter_utils` credentials against the backend before opening the dashboard, and clear credentials on `401` or `Guest` responses.

## Run Scripts

- When creating or editing a run script for a Flutter web app, always pass an explicit `--web-port` to `flutter run`; never rely on Flutter's random/default web port.
- For Flutter mobile apps, run scripts should parse and support a `-d` or `--device` argument to specify the target device, and pass through any remaining extra arguments directly to `flutter run`.
- When adding watch mode around `flutter run`, preserve interactive terminal input so Flutter CLI commands such as `r` for hot reload and `R` for hot restart still work. If `flutter run` must be backgrounded for a watcher, attach stdin from `/dev/tty` when available instead of leaving it detached.
- Use a stable default port per app and allow overriding it with a script argument such as `--port PORT` when practical.
- For Flutter web apps that call a local Frappe backend, pass an explicit `--web-hostname` matching the Frappe site host (for example `masar.localhost`) so Frappe Socket.IO origin checks pass.
- For `flutter_apps/masar_admin/`, use `masar.localhost:8001` by default through `run_masar_admin.sh` or `flutter_apps/masar_admin/run.sh`; the backend remains `http://masar.localhost:8000` and Socket.IO remains on the bench `socketio_port`.
- For Masar Admin realtime, prefer Frappe token auth over browser `sid` auth: keep Dio `withCredentials: false`, send normal API calls with `Authorization: token <api_key>:<api_secret>`, and connect Socket.IO with the same token in `extraHeaders`.
- Masar Admin Socket.IO URLs must include the Frappe site namespace. Local is `http://masar.localhost:9000/masar.localhost`; production is `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`. Production API calls still use `https://masarbackend.conceptiqs.com`.
- Use Socket.IO `path: /socket.io` and transports `['polling', 'websocket']` for the Flutter Frappe client.
- Use browser `sid` auth only as a fallback. If using `sid`, enable credentials on both Dio and Socket.IO; use polling-only (`transports: ['polling']`, `upgrade: false`) only when websocket handshakes do not include cookies.
- Document or print the selected environment, target entry point, and port before running the app.
- Do not run the app or start a dev server as routine verification for unrelated Flutter UI/code edits. Use `flutter analyze` unless the user asks to run the app or the change specifically affects run behavior.

## Splash Screen

- Use a splash screen as the app's entry point.
- On splash, perform:
  1. Load app configuration
  2. Check authentication state
  3. Pre-fetch common data (roles, lookups)
- Listen for auth state changes and navigate to **dashboard** (authenticated) or **login** (unauthenticated).
- Enforce a **minimum splash duration** so the screen does not flash.

## Local UI Preferences

- Persist non-sensitive shell preferences such as admin sidebar collapsed/expanded state in local storage through the app's shared preferences helper.
- Do not clear UI preferences on logout unless the user explicitly resets preferences; only clear auth/session credentials.

## WebView

- Use `flutter_inappwebview` for all webview needs.
- Also use `flutter_inappwebview` for HTML / rich text editors.

## HTML Rendering

- Use `flutter_widget_from_html_core` for displaying HTML content as Flutter widgets.
- Do not use `webview` for simple HTML rendering — only for interactive web content.

## Packages Summary

| Need | Package |
|------|---------|
| WebView | `flutter_inappwebview` |
| HTML display | `flutter_widget_from_html_core` |
| Rich text editor | `flutter_inappwebview` |
| Environment variables | `flutter_dotenv` or `.env` loader |
