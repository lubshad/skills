---
name: flutter-networking
description: Use when changing Flutter Dio clients, API calls, repositories, interceptors, network models, or Frappe realtime connections.
---

# Flutter Networking

Read `frontend-api-client.md` first; managed Frappe auth also needs `frappe-api-contracts.md`.

## Dio boundary

One configured **Dio** per backend; repositories create neither clients nor auth headers. Request interceptors read current credentials with explicit `extra` auth modes and protect client-owned headers. Error interceptors compare credential snapshot/generation and deduplicate expiration; restrict credential destinations/redirects and separate third parties.

Environment config owns API URLs and generic `apiHeaders`. Local mobile/emulator URLs use bridge/LAN IPs, not `*.localhost` (Android example `10.0.2.2:8000`). Every local platform sends `X-Frappe-Site-Name` for routing; prefer it to `Host`, which WebViews may ignore. Wrappers consume config, not platform/site decisions.

Token web uses `extra: {'withCredentials': false}`; cookie mode alone uses true. `dio_pretty_logger` is debug-only with sensitive headers/bodies redacted/omitted. Admin debug API tests add a one-second request delay, never profile/release.

Flutter Utils sites use token login: POST `flutter_utils.api.auth.login` JSON `{usr, pwd, device_id: installationUuid}` plus optional `device_name`. Persist `api_key`, `api_secret`, `authorization_source`; interceptors send Authorization and `Frappe-Authorization-Source`. Explicitly mark login/token exchange/OTP public, not the whole namespace (`logout_device` is authenticated). Validate stored tokens through `frappe.auth.get_logged_user`; Guest/401 clears auth and returns to login.

## Repositories and payloads

Widget → BLoC → repository → Dio. Repositories return parsed typed models, not raw responses. No repository try/catch, manual status-200 checks, or hardcoded UI validation: Dio throws; BLoC/global handlers catch. UI validates dynamic constraints; backend enforces them.

Frappe routes: `/api/method/<path>` (POST JSON), `/api/resource/<DocType>` (GET reads); multipart uses `FormData`.

## Socket ownership

One shared realtime service/connection per authenticated session/backend, not per widget/BLoC/screen. Screens acquire scoped leases; reference-count rooms (first subscribes, last unsubscribes), make duplicate lifecycle calls idempotent, filter events by lease, and never disconnect other owners. Retained `IndexedStack` screens must not open separate polling sessions: HTTP/1 limits can stall heartbeats and cause retries/unknown session IDs.

Socket URL is `{base}/{site_namespace}`, path `/socket.io`. Masar local: `http://masar.localhost:9000/masar.localhost`; production: `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`, while APIs use the backend host. Cross-domain frontends use their own origin with the `/socket.io` proxy from `setup-frappe-realtime.md`. Xealth bases are `adminpanel(-dev).xealth.ca`/`employee(-dev).xealth.ca`; APIs stay `backend(-dev).xealth.ca`.

Send the current `token`/`FlutterDevice` scheme in `extraHeaders`. Browsers cannot add arbitrary WebSocket headers: use polling for header auth unless a supported secure WebSocket mechanism exists. Native WebSocket headers work; no unauthenticated browser upgrade workaround.

One bounded recovery controller owns retries/credential validation; disable built-in reconnection if it competes. Restore each room once and invalidate data. On logout/credential change, stop/detach the old hub and acquire a fresh one. Use `doctype_subscribe`/`doctype_unsubscribe`; parse `list_update` map or one-item-array as an invalidation hint, then reload via repository/BLoC. Debug logs require `kDebugMode`.

## Images versus private files

Inline public `/files` and signed-image URLs load without auth/custom headers through normal browser-img fallback; headers force XHR/CORS failures. Private image APIs return directly browser-loadable signed URLs, not header workarounds.

Private attachment actions use `FrappeFileUrl.normalize` then `FrappeFileOpener.open` (`lib/core/utils/frappe_file_opener.dart`), not direct launchers/anchors/window.open. Fetch through `ApiClient.dio`; web opens authenticated bytes as a blob with MIME from headers/signature/name/extension. Pass `attachmentName`. Non-web defaults to external opening unless a viewer is required.

## Verification

Test shared-client/public/managed-read/logout modes, concurrent/stale 401s, headers, multipart, cancellation, site routing, and cookies; follow the shared-client checklist and focused tests/analysis. Test many leases on one socket, room overlap, scoped events, one reconnect/validation, final cleanup, and re-login with old leases. Browser checks span >2 heartbeats and retained-screen navigation; inspect packet bodies/queue timing, not HTTP status alone. Separate image CORS from realtime failures.
