---
name: flutter-document-approval
description: Use when implementing or reviewing Flutter linked-document listing, preview, file actions, or approval lifecycle.
---

# Flutter Document Approval

Read `frontend-admin-detail-pages.md`, `frontend-ui-states.md`, and `frontend-interaction-patterns.md` for placement/states/confirmation; then `flutter-common-widgets.md`, `flutter-dialogs.md`, and `flutter-networking.md`. Backend contracts: `frappe-document-approval-flow.md`, `frappe-file-images.md`.

## Ownership and display

Shared presentation uses generic `LinkedDocument` names, one public widget per snake_case file; models/repositories retain canonical API/DocType names. The tab owns load/mutation state unless the host BLoC already does. Cards receive typed data/callbacks, never make review requests. One working document ID disables only its mutation actions.

Show structured loading, true empty, human errors/retry, refresh/pull-to-refresh, and preserve loaded records when supported. Display available title/type/number, issue/expiry, lifecycle/approval statuses, reviewer/rejection, and attachment; missing values use `Not set`.

## Files and review

Normalize URLs before action eligibility. Fullscreen preview supported PDFs/images and retain authenticated open/download for every attachment. Use the shared Frappe opener, never direct private paths. Web PDFs use authenticated Dio bytes → temporary blob, revoked on viewer disposal.

Backend permission plus Pending allows Approve/Reject. Approval needs confirmation; rejection/revocation need nonempty reasons. Revoke only Approved; Reset to Pending only Rejected. Send expected current status to prevent stale overwrites. Block duplicates; success emits one message and reloads; failure preserves the list with a readable error.

Read `references/linked-documents.md` for widget mapping/integration and focused checks.

## Verification

Exercise loading/empty/error/retry/refresh/populated states, PDF/image preview, authenticated downloads, each valid review transition and reason requirement, duplicate prevention, and status refresh. Run `dart format` and `flutter analyze`.
