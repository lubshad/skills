---
name: flutter-document-approval
description: Use when implementing or reviewing Flutter admin linked-document listings, previews, downloads, approvals, rejections, revocations, resets, uploads, or removals.
---

# Flutter Document Approval

## When To Use

Use this skill for Flutter admin detail/profile surfaces that list documents related to a record and let an operator preview, open, download, approve, reject, revoke, reset, upload, unlink, or delete them.

Read these skills alongside it:

- `frontend-admin-detail-pages.md` for placement inside profile/detail tabs.
- `frontend-ui-states.md` for loading, empty, error, refresh, and retry behavior.
- `frontend-interaction-patterns.md` for confirmations and destructive actions.
- `flutter-common-widgets.md` for reusable widget boundaries and file actions.
- `flutter-dialogs.md` for confirmation, reason-entry, and fullscreen preview dialogs.
- `flutter-networking.md` for repository and authenticated attachment access.
- `frappe-document-approval-flow.md` for the canonical backend state machine, permissions, and APIs.
- `frappe-file-images.md` for private file URL and download rules.

## Composition

- Keep reusable linked-document presentation widgets under the app's shared widget directory.
- Use generic `LinkedDocument` widget names even when the backend canonical DocType has a product-specific name.
- Keep the backend model and repository naming aligned with the actual API contract; do not hide the canonical DocType identity in persistence code.
- Use one public widget per snake-case file.
- The linked-documents tab owns loading and review mutation state unless the host detail feature already has a BLoC that owns the same data.
- Cards receive a typed document plus callbacks. They must not issue approval or rejection requests directly.
- Use one working document ID so only the active document's mutation actions are disabled while the rest of the list remains readable.

## Listing And States

- Show structured loading, human-readable error with retry, and true empty states.
- Preserve loaded documents during refresh where the host state layer supports it.
- Support pull-to-refresh or the established desktop refresh action.
- Show title, type, number, issue/expiry dates, lifecycle status, approval status, reviewer details, rejection reason, and attachment name when available.
- Use plain missing-value copy such as `Not set`.

## Preview And File Actions

- Normalize attachment URLs before deciding whether preview/open actions are available.
- Preview supported PDFs and images in a fullscreen dialog.
- Keep an explicit authenticated download/open action for every available attachment.
- Use the shared Frappe file opener for protected files; never launch private Frappe paths directly.
- For web PDF preview, fetch bytes through the authenticated Dio client and render a temporary blob URL.
- Revoke blob URLs when the viewer is disposed.

## Review Actions

- Show Approve and Reject only when the backend says the operator can review and the current status is Pending.
- Require explicit confirmation before approval.
- Require a non-empty reason before rejection or approval revocation.
- Show Revoke only for Approved documents and Reset to Pending only for Rejected documents.
- Send the expected current status with review mutations so stale clients cannot silently overwrite a newer decision.
- Disable duplicate actions while a mutation is running.
- On success, show one clear message and reload the linked-document list.
- On failure, preserve the current list and show a human-readable error.

## Reference

Use `references/linked-documents.md` for the canonical widget map, integration pattern, and verification checklist.

## Verification

- Verify loading, empty, error/retry, refresh, and populated states.
- Verify preview for PDF and image attachments and authenticated open/download behavior.
- Verify Pending documents can be approved or rejected and rejection requires a reason.
- Verify Approved documents can be revoked and Rejected documents can be reset.
- Verify each mutation disables duplicate actions and refreshes the visible status after success.
- Run `dart format` on touched Dart files.
- Run `flutter analyze` for the Flutter app.
