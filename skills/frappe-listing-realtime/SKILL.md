---
name: frappe-listing-realtime
description: Use when Frappe-backed listings in Flutter, Next.js, Frappe Desk, or other clients must refresh from server-side changes.
---

Use this skill when a Frappe-backed listing in Flutter, Next.js, Frappe Desk, or another client must update after server-side create, update, delete, workflow, or background-job changes.

Read order:

1. Read `frontend-listing-screens.md` first for listing UX rules.
2. Read the platform adapter (`flutter-listing-screens.md`, `nextjs-listing-screens.md`, or `frappe-list-filters.md`) for implementation shape.
3. Read `frappe-realtime-updates.md` for general Frappe realtime semantics when backend code is also changing.
4. Use this file for the listing-specific realtime contract.

## Core Contract

- Prefer Frappe's standard `list_update` event for listing/index pages. Subscribe to the DocType room with `doctype_subscribe` and unsubscribe with `doctype_unsubscribe`.
- Use `doc_update` only for open detail/form pages for a single document.
- Do not invent custom realtime events for ordinary list row freshness. Custom events are only for domain-specific payloads that cannot be represented by document/list invalidation.
- Treat realtime payloads as invalidation hints, not complete row data. Refetch through the listing's normal repository/data layer so permissions, filters, formatting, and dynamic metadata stay consistent.

Expected `list_update` payload:

```json
{
  "doctype": "Athlete Profile",
  "name": "ATH-0001",
  "user": "admin@example.com"
}
```

Flutter Socket.IO clients may receive the payload as either the object above or as a one-item array containing the object. Parse both shapes and ignore updates with empty `doctype` or `name`.

## Backend Rules

- Prefer ORM writes (`insert`, `save`, `submit`, `cancel`, `delete_doc`) so `Document.notify_update()` publishes `doc_update` and `list_update` automatically after commit.
- Avoid `frappe.db.set_value`, raw SQL, and bulk DB writes for data that mounted listings must see in realtime unless you also publish the correct realtime event after the write is committed.
- For custom emission, publish after commit:

```python
frappe.publish_realtime(
	"list_update",
	{"doctype": doc.doctype, "name": doc.name, "user": frappe.session.user},
	doctype=doc.doctype,
	after_commit=True,
)
```

- If a backend flow calls external APIs or long-running work, persist local state first, commit/emit local freshness, then run the external work in a background job unless synchronous behavior is explicitly required.
- For custom generators, background jobs (`frappe.enqueue`), and scheduled tasks (`scheduler_events`) that modify docs a mounted listing must see, add a defensive explicit `publish_realtime("list_update", ...)` after `frappe.db.commit()` in addition to the standard `notify_update` path. See the "Defensive Emission" subsection of `frappe-realtime-updates.md` for the exact pattern and helper template. Client-side debounce collapses the duplicate events.

## External Client Pattern

- Put Socket.IO/Frappe realtime code in a small shared adapter. Do not scatter socket setup inside listing widgets/pages.
- Connect to the Frappe site namespace and authenticate using the app's normal session or token mechanism.
- For Masar Admin Flutter web, prefer token-auth Socket.IO over `sid` cookies: keep Dio `withCredentials: false`, send `Authorization: token <api_key>:<api_secret>` through Socket.IO `extraHeaders`, set `path: /socket.io`, and use transports `['polling', 'websocket']`.
- Build Flutter Socket.IO URLs as `{socket_base}/{site_namespace}`. Local Masar Admin uses `http://masar.localhost:9000/masar.localhost`; production uses `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`. The production API base remains `https://masarbackend.conceptiqs.com`; only the socket base host is `masaradmin.conceptiqs.com`.
- Use Frappe's normal `sid` cookie with Socket.IO `withCredentials` only as a fallback. For Flutter web `sid` auth, use polling-only if websocket upgrade requests omit the `Cookie` header: `transports: ['polling']`, `upgrade: false`, and credentials enabled.
- In local Frappe development, configure CORS for the Flutter origin. If using credentialed/cookie POSTs, also configure CSRF/referrer trust: `allow_cors` permits the browser request; `allowed_referrers` prevents CSRF rejection on credentialed POSTs.
- Ensure the Frappe Socket.IO Node process can build the backend URL correctly. In local bench development, `developer_mode` must be visible in `sites/common_site_config.json`, not only the site config, so Socket.IO rewrites `http://site:8001` to the webserver port `8000` for `/api/method/frappe.realtime.get_user_info`.
- Do not modify Frappe core middleware for realtime auth unless explicitly requested and scoped to an owned app/project boundary. Stock Frappe can authenticate Socket.IO with a real `Authorization` header when the client transport sends it.
- Subscribe only after the user is authenticated and has access to the target DocType.
- Listing screens subscribe while mounted and always unsubscribe/dispose on route exit.
- Debounce or batch rapid `list_update` events, roughly 300-750ms, before reloading.
- Reload the current list query by default, preserving search, filters, sort, page, page size, and selection behavior where applicable.
- Use row patching only when the platform already has reliable filter/sort membership checks; otherwise reload the current page.
- Preserve visible rows during background realtime refresh. Do not replace an already-loaded table with a full skeleton unless it is the first load.

## Flutter BLoC Pattern

- Keep realtime events as BLoC events, not direct widget mutations.
- Screen owns route-lifetime subscription if the listing BLoC is screen-scoped; global app services may own the socket adapter.
- Add a feature event such as `AthleteRealtimeChanged(name)` and handle it by calling the existing load method for the current page/query.
- Keep `Refresh` and realtime reload paths separate if manual refresh must force metadata refresh.
- Cancel timers, stream subscriptions, and doctype subscriptions in `dispose`.

## Verification

- Edit a visible record from another session and confirm the row updates without manual refresh.
- Change a field used by active filters and confirm the row appears/disappears according to the current filter.
- Create and delete records and confirm the current page refreshes correctly.
- Navigate away and back repeatedly and confirm duplicate network requests/listeners do not accumulate.
- Confirm realtime refresh failure preserves existing rows and shows the platform's normal retry/error behavior.
