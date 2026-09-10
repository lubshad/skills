---
name: frontend-api-client
description: Use when adding, changing, or reviewing frontend API calls, shared HTTP clients, authentication headers, credential persistence, or session-expiration handling on any platform.
---

# Frontend API Client

## When To Use

Apply to browser, mobile, desktop, and server-rendered frontend applications. Read this before the platform networking adapter. This skill owns shared transport and authentication behavior; adapters own library syntax, storage mechanisms, and project paths.

- Flutter implementation: `flutter-networking.md`.
- Next.js implementation: `nextjs-architecture.md`.
- Browser fetch implementation: [Browser client reference](references/browser-client.md).
- Frappe authentication contracts: `frappe-api-contracts.md`.
- Independent remote loads: `api-parallelization.md`.

## Client Boundary

- Use one configured client per backend/security boundary. Feature modules use that client, not direct transport calls or feature-local client instances.
- Centralize base URL resolution, authentication headers, credential policy, cancellation propagation, and session-expiration effects. A header helper that every endpoint must remember to invoke is not sufficient.
- Keep endpoint payloads, typed response parsing, and business-specific errors in repositories or feature API modules.
- Do not replace an established HTTP library merely to add interceptors. Do not patch global networking functions.
- Restrict authenticated requests to the intended backend. Validate resolved destinations; prevent redirects from forwarding credentials to other services. Third-party SDKs, signed assets, and payment providers have separate security boundaries.

## Authentication Modes

- Declare authenticated, public, and cookie-session requests explicitly. Do not infer public access from a broad URL prefix: login and authenticated logout may share a namespace.
- Read current credentials at dispatch time. Do not capture tokens once during client construction.
- Persist all authentication metadata required by the backend contract, not just the primary token. Retain legacy behavior only when actual persisted credentials or shipped consumers require it.
- Merge caller headers centrally and case-insensitively. Authentication headers are client-owned and cannot be overridden by feature code.
- Public calls must not carry stored tokens; cookie transmission must follow the explicit mode. Cookie-session writes retain the backend's CSRF requirements.
- Keep server-side credentials scoped to the incoming request. Never mutate a shared server client's defaults with a user's token or cache authenticated responses across users.
- Never log credentials, authorization headers, secrets, or sensitive authentication payloads.

## Failures And Concurrency

- Centralize authentication-expiration side effects and leave routing to the existing auth/UI layer. Individual endpoints must not emit duplicate logout events.
- Expire only the credentials used by the failed request. A delayed unauthorized response must not erase a newer login. Compare a credential snapshot or authentication generation before changing local state.
- Collapse concurrent unauthorized failures into one expiration event for that login. Public-login failures do not invalidate a separate stored session.
- Do not treat every forbidden response as an expired login; authorization denial and authentication failure are distinct.
- Preserve cancellation, request bodies, and timeout semantics. Aborted/network-failed requests must not automatically sign the user out.
- Do not introduce automatic mutation retries, refresh loops, or hidden serialization. Refresh/retry requires a documented backend contract and bounded behavior.

## Payloads And Errors

- Support JSON, form-encoded bodies, multipart uploads, and any response types needed by the application.
- Do not force a JSON content type on every request. Let the transport generate multipart boundaries.
- Keep a clear error contract: either return the response for feature parsing or throw a normalized error, following the established platform pattern. Do not consume response bodies before feature parsing without preserving them.

## Verification

- Test latest credential injection, auxiliary authentication metadata, header merging, and caller-override prevention.
- Test public/session modes, missing credentials, and rejection of unrelated destinations before transmission.
- Test multipart uploads, cancellation propagation, and unchanged endpoint payloads.
- Test one expiration event for concurrent failures and preservation of newer credentials after a stale failure.
- Test existing persisted credential formats where compatibility is required.
- Search application sources for direct backend transport calls outside the shared client; third-party SDK calls remain separate.
- Run platform tests, lint, type analysis/build, and representative login followed by authenticated reads when live access permits. Report unverified live behavior separately from mocked tests.
