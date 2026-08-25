---
name: flutter-networking
description: Use when adding or changing Flutter API calls, Dio clients, repositories, interceptors, errors, or network models.
---

Follow these networking rules strictly when working on Flutter code.

## HTTP Client

Use **Dio** as the sole HTTP client.

## Setup

- Retrieve base URL and configuration from the **app config** (loaded per environment).
- For local Frappe sites on mobile devices and emulators/simulators, do not use `*.localhost` as the request URL because mobile operating systems often cannot resolve it to the host machine. Instead, put the host's bridge IP or local network IP in app config (e.g., `http://10.0.2.2:8000` for Android emulators, or `http://192.168.x.x:8000` for iOS simulators/real devices). To ensure Frappe routes the request to the correct site locally, apply the `X-Frappe-Site-Name` header for ALL local environments (e.g., `X-Frappe-Site-Name: example.localhost`), not just Android. Prefer `X-Frappe-Site-Name` over a custom `Host` header because WebViews may ignore `Host` overrides while Frappe explicitly checks `X-Frappe-Site-Name`. Keep this platform/site decision in app config; the Dio client or WebView wrapper should only consume generic config values such as `apiBaseUrl` and `apiHeaders`.
- Set Dio `extra: {'withCredentials': false}` for token-auth Flutter web apps such as Masar Admin. Use `withCredentials: true` only for cookie-based auth.
- Add `dio_pretty_logger` as an interceptor for request/response logging.
- Add a fake 1-second Dio request delay in debug mode only for admin app API testing; never apply this delay in profile or release builds.
- For Frappe sites with `flutter_utils` installed, use token authentication from `flutter_utils` instead of Frappe's built-in `/api/method/login` session flow.
- For `flutter_utils` auth, call `POST /api/method/flutter_utils.api.auth.login` with JSON body `{ "usr": username, "pwd": password }`, store the returned `api_key` and `api_secret`, and send authenticated requests with `Authorization: token <api_key>:<api_secret>`.
- Do not send the `Authorization` header to `flutter_utils.api.auth.*` endpoints; those auth endpoints are guest-accessible and issue credentials.
- Verify an existing stored token by calling an authenticated endpoint such as `GET /api/method/frappe.auth.get_logged_user`; if it returns `Guest` or `401`, clear local auth state and route to login.

## Frappe Socket.IO

- Keep Frappe Socket.IO setup in a shared realtime service, not inside widgets or BLoCs.
- Build the socket URL as `{socket_base}/{site_namespace}`. For Masar Admin local use `http://masar.localhost:9000/masar.localhost`; for production use `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`.
- Keep API and socket hosts separate when needed. Masar Admin production HTTP APIs use `https://masarbackend.conceptiqs.com`; only Socket.IO uses the admin host `https://masaradmin.conceptiqs.com` as its base.
- Configure Socket.IO with `path: /socket.io`, transports `['polling', 'websocket']`, reconnection enabled, and `Authorization: token <api_key>:<api_secret>` in `extraHeaders`.
- Subscribe to Frappe DocType rooms with `doctype_subscribe`, unsubscribe with `doctype_unsubscribe`, and listen for `list_update`.
- Parse `list_update` as either a direct map or a one-item array containing the map; treat it as an invalidation hint and reload through the repository/BLoC path.
- Gate Socket.IO debug logs with `kDebugMode` after testing; do not print realtime diagnostics in production builds.

## Repository Pattern

```
Screen → BLoC → Repository → Dio (API Client)
```

- **No `try-catch` in repositories.** Let Dio throw on non-2xx responses. The BLoC or a global error handler catches exceptions.
- **No hardcoded UI validations in repositories.** Do not hardcode rigid field validations (like exact length checks for OTPs) in the repository layer. Constraints should be driven by dynamic configuration (e.g. `AuthSettings`) checked at the UI layer or enforced by the backend API.
- **No manual 200 checks.** Dio automatically throws `DioException` for non-success status codes — do not check `response.statusCode == 200`.
- **Typed responses.** Repository methods return typed model objects, not raw `Response`. Parse the JSON inside the repository.

## API Conventions

- All Frappe API calls go through `/api/method/<dotted.path>` or `/api/resource/<DocType>`.
- Use `POST` for whitelisted methods, `GET` for resource reads.
- Send JSON body with `Content-Type: application/json` for method calls.
- For file uploads, use `FormData` with Dio's multipart support.

## Frappe Inline Images

- In Flutter web/admin apps, render public Frappe `/files/...` URLs and backend-generated signed image URLs without `Authorization` or other custom request headers.
- Do not pass token headers to `Image.network`, `NetworkImage`, or `CachedNetworkImage` for inline images. Flutter web must use its normal browser `<img>` fallback for these URLs; custom headers force XHR loading, which can trigger CORS failures.
- Private image APIs must return signed URLs that the browser can load directly. Do not use inline-image headers as a substitute for backend URL normalization.

## Authenticated Frappe File Opening

- In Flutter web/admin apps, do not open Frappe private file URLs directly with `url_launcher`, `launchUrlString`, anchors, or `window.open`. Those requests do not include the token `Authorization` header and Frappe will treat them as `Guest`.
- For Masar Admin file/attachment buttons, normalize the URL with `FrappeFileUrl.normalize(...)`, then open it with `FrappeFileOpener.open(...)` from `lib/core/utils/frappe_file_opener.dart`.
- `FrappeFileOpener` must fetch bytes through `ApiClient.dio` so the existing token interceptor adds `Authorization: token <api_key>:<api_secret>`.
- On web, convert authenticated bytes to a blob URL and set a useful MIME type from response headers, file signature, attachment name, or URL extension before opening the blob.
- Pass `attachmentName` when available so MIME fallback and browser handling are more reliable.
- Keep non-web behavior as external app opening unless there is a platform-specific viewer requirement.
