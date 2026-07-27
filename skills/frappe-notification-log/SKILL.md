---
name: frappe-notification-log
description: Use when creating, changing, reviewing, or displaying Frappe Notification Log records and user notifications.
---

# Frappe Notification Log

## When To Use

Use this skill for backend notification producers, notification helpers, notification APIs, email-backed alerts, and frontend Notification Log displays.

Read `frappe-python.md` for backend implementation and `frappe-api-contracts.md` when notifications are consumed by Flutter, Next.js, or another external client.

## Required Content

Every user-facing notification must have both:

- A concise title describing what happened.
- A detailed description explaining the affected record, relevant reason or status, and the user's next step.

Do not create title-only notifications. Do not use a generic description when the backend has specific context such as a document title, event title, rejection reason, expiry date, or approval result.

## Frappe Field Mapping

Frappe's standard `Notification Log` fields are:

- `subject`: the notification title displayed by clients.
- `email_content`: the detailed notification description/message.

`title` and `description` are not standard `Notification Log` fields. Never write those keys into a `Notification Log` document or query them in filters. Application helpers may expose semantic arguments named `title` or `description`, but they must map them to `subject` and `email_content` before persistence.

## Message Quality

- Keep `subject` short and action-oriented, for example `Document changes requested`.
- Make `email_content` self-contained and specific.
- Include the affected entity by human-readable title when available.
- Include a rejection reason, status, date, or other relevant detail.
- End with the expected next action when the user needs to respond.
- Avoid putting the entire description in `subject`.

Example:

```python
{
	"subject": "Document changes requested",
	"email_content": (
		'Your document "Identity Document" requires changes. '
		"Reason: The document has expired. "
		"Please upload a corrected document and resubmit it for verification."
	),
	"type": "Alert",
	"document_type": "Masar Document",
	"document_name": document.name,
}
```

## Safety And Delivery

- Escape user-provided plain text before storing it as HTML in `email_content`.
- Use ORM insertion or Frappe's `enqueue_create_notification`; do not use raw SQL.
- Ensure queued creation runs after commit so rolled-back actions do not notify users.
- Include `document_type` and `document_name` for traceability.
- Add a client-appropriate `link` when the referenced DocType is not directly routable in that client.
- Deduplicate retries using real fields such as recipient, reference, subject, and message. Do not pass unsupported keywords to Frappe helpers.
- Keep the recipient permission boundary explicit; never trust a client-supplied recipient without backend authorization.

## Frontend Contract

- Render `subject` as the title.
- Render `email_content` as the detailed description.
- Treat stored HTML as untrusted unless the backend guarantees escaping or sanitization.
- Keep title and description visible in list cards; do not require opening a detail page to understand the notification.
- Preserve loading, empty, error, unread, and read states according to the platform UI guidance.

## Verification

- Assert every produced payload contains non-empty `subject` and `email_content`.
- Assert payloads do not contain `title` or `description` keys.
- Verify dynamic values are escaped before HTML rendering.
- Verify duplicate retries do not create identical notifications.
- Verify a rolled-back transaction does not produce a notification.
- Verify the target client displays both title and detailed description.
- Verify links open the intended client route.
