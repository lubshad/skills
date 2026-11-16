---
name: frappe-realtime-updates
description: Use when backend changes must refresh mounted clients through Frappe document, listing, or background-job events.
---

# Frappe Realtime

Read matching shared UI rules before adapters: listings use `frontend-listing-screens.md` → adapter → `frappe-listing-realtime.md`; admin details use `frontend-admin-panels.md` → `frontend-forms.md` → `frontend-ui-states.md` → `frontend-admin-detail-pages.md` → adapter; Desk filters use `frontend-admin-panels.md` → `frappe-list-filters.md`.

## Persist before notifying

Prefer ORM insert/save/submit/cancel/delete and `Document.notify_update()`. Raw SQL/`db.set_value` needs explicit correct notifications after persistence. Custom pre-commit publication uses `after_commit=True`; never signal rollbackable state. External/long work persists local state first, then runs in background unless explicitly synchronous.

Events:
- `doc_update`: `{modified, doctype, name}`, routed with doctype/docname to `doc:<Doctype>/<name>` for active details.
- `list_update`: `{doctype, name, user}`, routed to `doctype:<Doctype>` for listings/reports.
- `docinfo_update`: document metadata/sidebar/comments only. User-specific events pass `user`, not shared list freshness.

Custom events are for payloads standard invalidation cannot represent.

## Defensive worker/generator emission

Custom whitelisted generators, jobs, and scheduled tasks supplement ORM notifications with **commit → immediate publish of both events**, without `after_commit=True` after that commit (another worker commit may never occur). Centralize in a per-DocType helper. Independent loop records commit/emit individually for partial progress; all-or-nothing records commit/emit once after the loop. Debounce duplicates 300–750ms. Not for standard CRUD/Desk or a replacement for ORM.

## Consumers

Desk uses native list realtime; keep auto-refresh enabled unless explicitly manual. Subscribe by DocType; refetch changed names against active filters, then append/update/remove/sort/render. Avoid repeated refresh during bulk work/filter editing; preserve supported selection/query/page/scroll.

Details subscribe only to current ID and refetch authoritative payloads. Remote updates must not overwrite unsaved drafts: show conflict/refresh-needed state. Local saves update state immediately without duplicate visible reload. Release listeners on route/modal exit or ID change.

External clients share one connection per authenticated session/backend with scoped listeners and reference-counted rooms. Release last owner only; recover each room once with one bounded retry/auth controller. Logout/replaced credentials invalidate the hub; stale consumers cannot reconnect under a newer session. Centralize typed event/room/payload contracts. Subscribe only after authorization; bound reloads to affected row/page except intentionally tiny lists.

Masar URLs: local `http://masar.localhost:9000/masar.localhost`; production `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`; APIs remain `https://masarbackend.conceptiqs.com`. Preserve current credential scheme (`token` legacy, `FlutterDevice` managed) on `/socket.io`. Browser header auth uses polling unless secure WebSocket auth is supported; native headers work. Many retained-screen polling sockets can exhaust HTTP slots—inspect queued handshakes/heartbeats/session errors instead of increasing retries/timeouts.

Local Node auth must target Frappe, not Flutter: Bench developer_mode rewrites Origin port to webserver_port; restart Node after changing it, never enable production developer_mode as a workaround. Separate production domains use `setup-frappe-realtime.md`: frontend `/socket.io/` proxy with backend namespace, Host/Origin/site header/auth destination, Authorization, GET/POST, and upgrade forwarding. CORS alone does not override origin validation.

## Verification

Check cross-session/job create/edit/delete/cancel/archive, active-filter membership, row/detail freshness, protected unsaved drafts, and no listener/request growth. With many consumers verify one connection/unique rooms over ≥2 heartbeats, recovery and logout/re-login; inspect socket bodies, not HTTP statuses alone.
