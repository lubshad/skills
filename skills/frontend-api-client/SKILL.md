---
name: frontend-api-client
description: Use when changing frontend API calls, shared clients, auth headers, credential storage, or session-expiration handling.
---

# Frontend API Client

Shared transport/auth behavior for browser/mobile/desktop/SSR. Read before platform adapters: `flutter-networking.md`, `nextjs-architecture.md`, or [browser client](references/browser-client.md). Frappe auth adds `frappe-api-contracts.md`; independent loads `api-parallelization.md`; prototype integration `frontend-design-consistency.md` (not transport-only visual audits).

## One client per security boundary

Features use the configured client, not direct transport/local clients. Centralize base URL, auth/credential policy, cancellation, and expiration; an optional header helper is insufficient. Features retain payloads, typed parsing, and business errors. Keep the established HTTP library; no global networking patches.

Validate resolved destinations and redirects before transmitting credentials. Third-party SDKs, signed assets, and payments remain separate boundaries.

Explicit request modes: authenticated, public, cookie-session—not inferred namespace prefixes. Read latest credentials at dispatch and retain all contract-required metadata/necessary persisted compatibility. Merge headers case-insensitively; features cannot override client auth. Public calls carry no stored tokens; cookie writes retain CSRF. Server credentials stay request-scoped, never mutable shared defaults or cross-user caches. No secret/header/auth-payload logs.

## Web authentication boundaries

For static React apps that require managed-device API login, use the direct-token setup in the [browser client reference](references/browser-client.md). It uses origin-scoped `localStorage` so tabs share a login without a server runtime. Do not apply this storage policy to other authentication modes.

For server-backed web apps, prefer a same-origin BFF. Keep upstream secrets, refresh tokens, and source metadata server-controlled, in sessions keyed by opaque HttpOnly cookies or purpose-bound authenticated-encrypted HttpOnly payloads. HttpOnly alone is not encryption. Keep BFF credentials out of browser storage and browser-visible responses.

Hosted cookies need Secure, explicit SameSite, host-only scope, bounded expiry; keys stay private runtime config, never committed/public env. Local HTTP exceptions cannot weaken hosted settings. Cookie-auth BFF writes—including login/logout—check exact configured Origin and expected content type or CSRF token. Reject caller-selected upstream destinations/credential redirects.

Server validates current credentials/authorization for protected routes and every feature API; cookie presence/client guards are not authorization. Return minimal user metadata, no-store responses. Browser-cookie and backend-token modes remain distinct, preserving all upstream headers. Stable installation UUID is non-secret; native clients retain secure storage contracts.

Logout revokes supported upstream device/refresh credentials, then clears browser auth; disclose failed revocation/local-only logout. Existing direct-token apps need deliberate documented migration, not silent breakage.

## Failures and bodies

One expiration effect per login, routed by existing auth/UI. Compare failed-request credential snapshot/generation: stale unauthorized results cannot erase a newer login. Public-login failures do not invalidate unrelated sessions; 403 authorization denial is not automatically expiration. Network/abort/timeout failures preserve auth and request semantics.

No hidden mutation retries, refresh loops, or serialization; retry/refresh needs a documented bounded contract. Preserve JSON, forms, multipart boundaries, required response types, and feature-readable bodies. Follow established response-or-normalized-error convention; parsing must not consume bodies irretrievably.

## Verification

Test current/auxiliary credentials, protected header merge, public/cookie/missing-auth modes, destination rejection, multipart/cancellation/payloads, concurrent expiration and stale failures, and required legacy formats. For BFF check no secret leakage, tamper/expiry fail-closed, hosted flags, cross-origin denial, server authorization, and live revocation. Search for direct backend calls outside the client (third parties separate). Run platform tests/lint/types/build and representative live login/read when available; distinguish live from mocks.
