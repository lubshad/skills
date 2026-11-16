---
name: frappe-document-approval-flow
description: Use when implementing Frappe document upload, private verification, approval/rejection state, review audit, or reusable review APIs.
---

# Document Approval

One canonical document DocType owns attachment, `approval_status` (Pending/Approved/Rejected), and `rejection_reason`. An optional audit DocType records who/when, never current-state truth.

## Permissions and lifecycle

Sensitive personal/verification uploads use File `is_private: 1`; external APIs return shared-helper signed URLs, never raw private paths. Users access only their own/managed-profile documents through backend permission hooks/checks. Review APIs require a specific admin role, not frontend visibility alone.

Separate user upload/list/delete APIs from admin approve/reject. Use ORM insert/save rather than SQL/`db.set_value` so standard realtime publishes. This flow's write methods explicitly commit at completion.

New uploads start Pending; rejection requires a reason. Replacing a rejected attachment resets Pending and clears reason. Desk shows Approve/Reject only for pending records and permitted admins; Reject prompts for reason.

## References and verification

Read by changed branch: [schema](references/generic-document-doctype.md), [APIs](references/generic-document-api.md), [Desk actions](references/generic-document-desk-approval.md), [implementation checklist](references/generic-implementation-checklist.md). Flutter listing/preview/review uses `flutter-document-approval.md`.

## Verification

Check private attachment access, owner/admin boundaries, required reasons, replacement reset, ORM/realtime behavior, and the applicable reference checklist.
