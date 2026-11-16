---
name: frappe-api-contracts
description: Use when creating, editing, or reviewing Frappe APIs consumed by external clients.
---

# Frappe API Contracts

Not for Desk-only methods. Implementation also reads `frappe-python.md`; file/image changes use `frappe-file-images.md`, outbound/long work `frappe-async-external-apis.md`.

## Stable responses

Prefer additive changes; preserve consumed fields/types. Share private serializers across read/create/update. Normalize public files and `/assets/<app>/...` to absolute URLs, private files to signed downloads; no raw private paths or per-endpoint format drift. Clients should not reconstruct backend URLs. Keep image/cover fields consistent across all flows.

**IDs persist; titles display.** Every linked value in list/detail/write/search responses includes its canonical name/ID and permitted readable title from `title_field` (for example Guardian `guardian_name`). Configure Desk `show_title_field_in_link` where appropriate; never rename documents or store titles instead of IDs. `search_link` may return ID-valued `label` despite a readable description; consumers prefer readable title/description, retain selected labels, and resolve saved links. Respect permissions; safe fallback must neither expose restricted text nor clear stored links. IDs may disambiguate duplicate titles.

## Managed device auth

Read `frontend-api-client.md`; backend-scoped clients own headers. Generate/persist one random installation UUID per installation/browser profile, not hardware ID or per-login UUID. `device_name` is optional.

Persist `api_key`, `api_secret`, and `authorization_source` together. Managed source is `Flutter Device Credential`; send `Authorization: token <api_key>:<api_secret>` plus `Frappe-Authorization-Source: Flutter Device Credential`, otherwise Frappe looks up User keys. Supported old User tokens may omit source; do not guess device provenance.

Web retains the tuple server-side or in authenticated-encrypted HttpOnly cookies behind a BFF. Browser cookie auth is not a Frappe session; BFF still uses backend token mode. Stable browser UUID is non-secret. Login/token exchange/OTP issuance are explicitly public; `logout_device` is authenticated despite the namespace. Cookie-session APIs remain distinct, including CSRF.

Verify deployed login **and subsequent authenticated read**; issuance mocks miss absent schema/headers.

## Verification

Check series-named links in search, after selection, and after reopening; submit original IDs, including duplicate/restricted/missing titles. Check permission-limited responses, compatible list/detail/write names and asset formats, and additive compatibility.
