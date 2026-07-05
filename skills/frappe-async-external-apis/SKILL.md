---
name: frappe-async-external-apis
description: Use when Frappe backend code calls external APIs, webhooks, storage providers, or long-running remote services.
---

Follow these async integration rules strictly when working on Frappe code that talks to external systems.

## When To Apply

- Apply this skill for any backend change that calls an external API, webhook target, payment gateway, storage provider, or other network service.
- Apply it alongside `frappe-python.md` for implementation work.
- Apply it alongside `frappe-api-contracts.md` when the endpoint is consumed by Flutter, Next.js, or another external client.

## Core Rule

- Do not block the request on external API calls or other long-running functions unless the user explicitly requires synchronous behavior.
- Prefer saving local intent or state first, then enqueueing background work with Frappe jobs.

## Request Design

- Keep request handlers fast and predictable.
- Validate inputs in the request, persist the local document or task state, and return immediately.
- Record enough local metadata to track queued, in-progress, completed, and failed external work.

## Background Execution

- Use `frappe.enqueue(..., enqueue_after_commit=True)` or a dedicated background job helper for outbound API work.
- Make background jobs idempotent where possible so retries do not create duplicates externally.
- Log unexpected failures with `frappe.log_error()` and persist a user-visible sync status on the document when relevant.

## Sync Patterns

- For create flows, create the local record first when possible and mark it as pending sync before the background job runs.
- For update flows, store the local change and enqueue the external sync unless strict synchronous confirmation is required.
- For delete flows, prefer background deletion of the external resource and do not block the user request on the remote API.
- For long-running external processing, add polling or scheduled sync jobs until a terminal state is reached.

## User Experience

- Expose clear local status fields such as `queued`, `syncing`, `complete`, or `failed`.
- Add manual retry or sync actions when the feature benefits from operator control.
- Do not make the UI wait on remote processing when a local pending state is sufficient.
