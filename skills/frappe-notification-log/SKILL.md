---
name: frappe-notification-log
description: Use when producing, querying, reviewing, or displaying Frappe Notification Log alerts.
---

# Notification Log

Backend reads `frappe-python.md`; external clients also read `frappe-api-contracts.md`.

**Title plus explanation.** Persist a concise action-oriented `subject` and self-contained `email_content` naming the readable entity, relevant reason/status/date, and next action. No title-only/generic messages when context exists; do not stuff detail into the subject.

`title`/`description` are not standard fields: helper arguments must map to `subject`/`email_content` before writes or queries. Example: “Document changes requested” / “Your Identity Document has expired. Upload a corrected document and resubmit.”

## Delivery and display

Escape user plain text before HTML storage. Use ORM or `enqueue_create_notification`, after commit so rollback never notifies. Include `document_type`/`document_name`, plus a client-appropriate link when not directly routable. Deduplicate retries with real recipient/reference/subject/message fields, not unsupported helper keywords. Authorize recipients server-side.

Clients display subject and detailed content directly in list cards, treat HTML as untrusted unless guaranteed escaped/sanitized, and preserve loading/empty/error/unread/read states.

## Verification

Assert both standard fields are nonempty and no `title`/`description` document keys exist. Check escaping, retry deduplication, rollback suppression, both visible texts, and intended client links.
