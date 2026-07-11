---
name: frappe-api-contracts
description: Use when creating, editing, or reviewing Frappe APIs used by Flutter, Next.js, mobile apps, or external clients.
---

Follow these API contract rules strictly when working on Frappe-backed features.

## When Not To Apply

- Do not use this skill for Frappe Desk-only methods with no external consumer.
- Use it alongside, not instead of, `frappe-python.md` for endpoint implementation.

## Read Alongside

- Backend implementation: `frappe-python.md`.
- Files or images: `frappe-file-images.md`.
- External or long-running work: `frappe-async-external-apis.md`.

## When To Apply

- Apply this skill for any Frappe API that is consumed by Flutter, Next.js, or other external clients.
- Apply it alongside `frappe-python.md` for backend implementation work.

## Response Shape

- Keep API response fields stable once a frontend consumes them.
- When expanding a response, prefer additive changes over breaking shape changes.
- If create or update endpoints return records, return the same normalized field format used by the corresponding read endpoint.

## Asset URLs

- Do not return raw private file paths to clients.
- For file and image fields, return directly usable client values:
  - public files should resolve to full absolute URLs
  - public app assets such as `/assets/<app>/...` should also resolve to full absolute URLs
  - private files should resolve to signed download URLs
- Reuse shared helpers for URL normalization instead of duplicating logic per endpoint.

## Client Compatibility

- Assume Next.js and Flutter clients should not reconstruct backend file URLs on their own.
- Avoid mixing relative paths, absolute URLs, and signed URLs for the same response field across endpoints.
- Do not leave app asset paths as relative `/assets/...` values in API responses; normalize them to absolute URLs before returning.
- If an endpoint returns `image`, `cover_image`, or similar fields, keep the contract consistent across list, detail, create, and update flows.

## Shared Patterns

- Put reusable response-building logic in shared private helpers instead of repeating payload assembly in each whitelisted method.
- When a feature has both read and write endpoints, prefer one serializer/helper so all flows return the same normalized shape.

## Verification

- Verify authenticated and unauthorized responses do not expose fields beyond the caller's permissions.
- Verify list, detail, create, and update responses use compatible field names and normalized asset URLs.
- Verify additive changes preserve existing response fields and types for active clients.
