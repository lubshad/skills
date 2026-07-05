---
name: frappe-file-images
description: Use when Frappe APIs upload, store, attach, return, or transform files and image fields.
---

Follow these file and image API rules strictly when working on Frappe apps.

## When To Apply

- Apply this skill for any backend API that accepts, stores, transforms, or returns files or image fields.
- Apply it alongside `frappe-python.md` for whitelisted methods and shared API helpers.

## Uploads

- Create uploaded files through the `File` doctype using `frappe.get_doc({"doctype": "File", ...})`.
- Always attach files to the owning doctype, document, and field.
- Choose privacy intentionally:
  - Use `is_private: 0` for public assets that can be exposed directly.
  - Use `is_private: 1` for protected assets that must not be exposed as raw file paths.

## API Responses

- Never return raw `/private/files/...` paths from API payloads.
- When an API returns image or file URLs, normalize them through a shared helper before building the response payload.
- In Masar, use `get_signed_image_url_map()` from `apps/masar/masar/api/_utils.py` for image fields.

## URL Rules

- If the stored file is public (`/files/...`), return a full absolute URL with `frappe.utils.get_url(...)`.
- If the stored value is a public app asset (`/assets/<app>/...`), return a full absolute URL with `frappe.utils.get_url(...)`.
- If the stored file is private (`/private/files/...`), return a signed download URL instead of the raw path.
- If the value is already a full external URL (`https://...`), keep it unchanged.

## Shared Helper Pattern

- Prefer one shared private helper in `api/_utils.py` instead of reimplementing file URL logic in each endpoint.
- Endpoint modules should pass all relevant image fields into the helper, then map response fields from the normalized result.
- Reuse the same helper in profile, lookup, onboarding, and history APIs so clients receive one consistent URL format.

## Client Contract

- API consumers should receive a directly usable URL, not a relative private path that requires client-side reconstruction.
- Keep response field names stable (`image`, `cover_image`, `file_url`, etc.) even if the storage or signing logic changes internally.

## Flutter Admin Private File Access

- Frappe private file download endpoints still enforce file/document read permission. If a Flutter web app opens the URL directly in a browser tab, the request may arrive as `Guest` because token headers are not included.
- For Masar Admin, backend APIs should continue returning normalized public URLs or signed private download URLs, but frontend attachment actions must open private files through `FrappeFileOpener.open(...)` so the request goes through authenticated Dio.
- Do not fix private attachment failures by making protected documents public unless the product explicitly requires public access.
- If a direct browser-open experience is required for protected files, add a dedicated authenticated backend endpoint that verifies the owning document access before streaming the file; do not bypass Frappe permissions globally.
