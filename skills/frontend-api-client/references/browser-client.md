# Browser Client Adapter

For React/Vite or other browser apps already using native fetch, use a backend-scoped wrapper instead of introducing Axios solely for interceptors.

- In Zeronic, the wrapper is `frappeFetch` in `react_apps/zeronic/src/lib/frappe-api.ts`.
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

Do not import browser credential storage into server-rendered code. Next.js server routes use request-scoped credentials through their existing server client.
