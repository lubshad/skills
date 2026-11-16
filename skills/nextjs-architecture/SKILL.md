---
name: nextjs-architecture
description: Use when changing Next.js masarnext modules, API routes, shared utilities, or architecture.
---

# Next.js Architecture

For `next_apps/masarnext/`. Networking first reads `frontend-api-client.md`.

## Ownership

`src/app/` holds App Router pages/API routes; `features/` business modules; `components/` shared UI; `lib/` utilities; `data/` shared guest lookup fetchers; `types/` global declarations.

Each `features/<name>/` owns `components/` with colocated CSS Modules, `server/` backend functions, and `types.ts`. No importing another feature's server internals or multi-feature god files; cross-feature code goes through `lib/`/`data/`.

API paths mirror ownership (`/api/auth/`, `/api/profile/`, `/api/registration/`), not everything under auth. Routes stay thin: parse → request credentials → feature server function → JSON.

## Shared transport

`lib/frappeClient.ts` owns `callAuthedMethod`, `callAuthedFormData`, `callGuestMethod`, and `FrappeResult<T>`. `lib/apiBaseUrl.ts` owns `getApiBaseUrl`/`normalizeAssetUrl`. Import, never duplicate.

Existing Masar browser calls use `postAuthedJson`/`postAuthedFormData` from `features/auth/client/authClient.ts`; server routes use `getRequestAuthCredentials` from `features/auth/server/requestAuth.ts`. Centrally inject all required auth metadata, preserve explicit guest/multipart modes, validate destinations, and separate third parties. Browser credentials are read at dispatch; server credentials are request-scoped, never shared mutable defaults/caches. Expiration effects belong in browser auth, not global server state.

## New web token auth

Use a same-origin BFF: server-only credentials/codec/keys, opaque server sessions or purpose-bound authenticated-encrypted HttpOnly cookies, validated expiry and hosted Secure/host-only flags. No upstream secrets in browser props/JSON or `NEXT_PUBLIC_*`.

Cookie writes, including login/logout, require exact configured Origin/CSRF checks. Reject arbitrary upstream URLs and credential redirects. Independently authorize every API and protected document/RSC navigation using current identity/roles; layout/Proxy redirects or caller identity headers are insufficient. Overwrite internal identity headers. Authenticated fetches are uncached. Read installed Next.js docs for async cookie/header and route/Proxy APIs. Existing direct-token names are compatibility, not the new-app storage model.

## Components

Browser APIs/hooks require `"use client"`; server helpers/routes exclude it. Hooks precede early returns. CSS Modules use shared design variables, not hardcoded colors/spacing. Reuse `src/components/ui/EmptyState.tsx`. Listings follow `nextjs-listing-screens.md`: first page only, then Load more.

## Verification

Run lint/type/build/auth checks for installed Next.js. Check protected document/RSC/API rejection of invalid/revoked credentials, no leakage/cross-user caching, cookie encryption/expiry/flags, exact-Origin checks, upstream headers, and logout revocation.
