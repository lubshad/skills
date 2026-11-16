---
name: frappe-file-images
description: Use when Frappe APIs accept, store, attach, transform, or return files/images.
---

# Frappe Files and Images

Read `frappe-python.md` for implementation. Create through `frappe.get_doc({"doctype": "File", ...})`, attached to owner DocType/document/field. Explicit privacy: `is_private: 0` public, `1` protected.

## One normalization boundary

Shared private helpers (prefer `api/_utils.py`) normalize every endpoint's relevant fields before serialization. Masar images use `get_signed_image_url_map()` in `apps/masar/masar/api/_utils.py`.

- Public `/files/...` and `/assets/<app>/...`: absolute `frappe.utils.get_url(...)`.
- Private `/private/files/...`: signed download URL, never raw path.
- Existing external HTTPS URLs: unchanged.

Reuse across profile/lookups/onboarding/history; clients receive directly usable URLs and stable `image`, `cover_image`, `file_url` names despite internal signing/storage changes.

## Protected downloads

Frappe still enforces file/document read permissions. Direct token-web tabs may arrive as Guest. Masar attachment actions use authenticated Dio through `FrappeFileOpener.open(...)` even while APIs return normalized/signed URLs. Do not make protected documents public to repair downloads without product approval. A required direct-browser experience needs a dedicated authenticated endpoint verifying owner-document access before streaming, not global permission bypass.

## Verification

Check owner attachment/privacy, each URL class, stable response fields, authenticated downloads, and denied access without public exposure.
