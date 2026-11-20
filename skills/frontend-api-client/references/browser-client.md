# Browser Client Adapter

For React/Vite or other browser apps already using native fetch, use a backend-scoped wrapper instead of introducing Axios solely for interceptors.

For server-backed web apps using a BFF, browser requests use same-origin endpoints with cookie credentials; only the server sends upstream token headers. For static React using managed-device API login, follow the direct-token setup below.

- Feature calls provide `/api/` paths and request options. The client owns token headers; `auth: "none"` marks public requests and `auth: "session"` preserves cookie sessions.
- Resolve and validate paths against the configured backend before reading credentials. Reject absolute/external paths and disallow redirects for token API calls.
- Use `Headers` to merge object, tuple-array, and Headers inputs case-insensitively. Remove caller-supplied credential headers before applying the selected mode.
- Default token/public calls to `credentials: "omit"`; cookie-session calls use `include` and the application's CSRF contract.
- Preserve `AbortSignal`, `FormData`, and URLSearchParams bodies. Do not manually set a multipart boundary.
- Return the original Response for endpoint parsing. Central unauthorized-response handling must not consume its body.
- Use a request credential snapshot or generation to prevent stale 401 responses from clearing a newer login. Avoid credential logging.

```ts
const response = await frappeFetch("/api/method/example.get_profile", { signal });

const response = await frappeFetch("/api/method/example.login", {
  auth: "none",
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(payload),
});
```

Do not import browser credential storage into server-rendered code. Server routes use request-scoped credentials through their own client.

## Static React managed-device login

- Call the configured backend origin directly. Allow the app's exact origin and required headers in backend CORS. Use HTTPS in hosted environments. This setup does not require a proxy, session cookie, or extra service.
- Store only the validated API key, secret, and authorization source in `localStorage` using an app-specific key. Use a stable, non-secret installation UUID for device identity. Separate apps by origin when they need separate logins. Keep credentials out of React state, URLs, logs, and messages.
- Restore login by validating the device credential with the backend when the app starts. Listen for storage changes across tabs. Clear the signed-in UI when the credential is removed; revalidate changes before using a replacement. Late failures must not clear a newer login. Do not restore an old tab-only credential after logout.
- Revoke the device on the backend at sign-out, then clear the stored credential and signed-in UI across tabs. If revocation fails, still clear browser auth and report that server revocation was not confirmed. Direct API login does not configure realtime routing.

**Storage risk:** `localStorage` persists after the browser closes. JavaScript on the app's origin can read it, so an XSS flaw can expose a reusable credential. Document this tradeoff; do not treat browser storage as equivalent to HttpOnly storage.

## Verification

Check fresh independent tabs, isolation between app origins, cross-tab logout, rejected revoked credentials, failed revocation, and stale requests after token rotation. Verify a real authenticated request against the intended backend and distinguish it from mocked browser tests.
