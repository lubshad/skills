---
name: frappe-listing-realtime
description: Use when Frappe-backed listings must refresh after server-side create, update, delete, workflow, or job changes.
---

# Frappe Listing Realtime

Read `frontend-listing-screens.md`, then the Flutter/Next.js/Desk listing adapter. Backend changes also read `frappe-realtime-updates.md`.

**Events invalidate; repositories load.** Prefer standard `list_update` in the DocType room via `doctype_subscribe`/`doctype_unsubscribe`; `doc_update` is for one open detail. Custom events require genuinely domain-specific payloads. Refetch through normal data paths to preserve permissions/filters/metadata.

## Server

ORM insert/save/submit/cancel/delete triggers `Document.notify_update()` after commit. Low-level writes require explicit post-commit notification. Custom list payload: `{doctype, name, user}`, with DocType routing and `after_commit=True` before commit. External work persists local state/freshness first, then runs in a job unless explicitly synchronous.

Custom generators/workers/schedulers additionally commit then defensively emit list/doc updates immediately as specified in `frappe-realtime-updates.md`; client debounce absorbs duplicates.

## Client

Use one shared authenticated site-namespace adapter, not socket setup in widgets. Parse map or one-item-array payloads; ignore empty DocType/name. Subscribe only with target access and clean up route subscriptions/timers/listeners. Debounce bursts 300–750ms, reload the current query while preserving filters/search/sort/page/size/selection and visible rows. Patch rows only with reliable membership/sort checks; refresh failures keep data.

Masar web prefers token headers and Dio `withCredentials: false`, socket `/socket.io`; browser header-auth transport restrictions follow `flutter-networking.md`. Local URL: `http://masar.localhost:9000/masar.localhost`; production socket: `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`; APIs stay backend-hosted. Cookie fallback needs credentials, polling-only/upgrade false if WebSocket omits cookies.

Local origins need CORS and credentialed POST referrer/CSRF trust. Node auth must target Frappe: Bench `common_site_config.json` developer_mode makes local routing use webserver port 8000 rather than Flutter 8001. Do not patch Frappe middleware merely for stock header authentication.

Flutter sends realtime BLoC events to existing current-page load methods; screen owns scoped lifetime, service owns socket. Keep manual metadata-force-refresh separate; dispose timers/streams/DocType rooms.

## Verification

Cross-session create/edit/delete and filter-membership changes refresh current rows without navigation/manual refresh. Repeated route entry adds no listeners/requests; failure retains rows with normal retry feedback.
