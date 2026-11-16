---
name: setup-frappe-realtime
description: Use when connecting or repairing Frappe Socket.IO across frontend domains, nginx proxies, or origin/namespace failures.
---

# Frappe Realtime Connection

Read `frappe-realtime-updates.md`, the networking adapter, relevant web-deployment adapter, and `project-connections.md`.

**Frontend origin, backend namespace.** Installed `realtime/middlewares/authenticate.js` checks hostname(Host)==hostname(Origin), with namespace matching site from `X-Frappe-Site-Name`. REST `allow_cors` does not repair Socket.IO origin checks. Connect browser → frontend `/socket.io` → nginx → realtime, rewriting Host/Origin/site header to backend.

## Managed proxy

Use `.agents/scripts/add_socketio_proxy.sh --frontend <host> --backend <host> [--ssh-key PATH]`. Options: ssh user/key/port, config/server-name/socket-target; dry-run/check/remove/test/reload; `--config-file` edits locally without SSH. Helper backs up, edits, tests nginx, reloads, and restores backup on failure.

`socketio_proxy_config.py apply|remove|check` owns idempotent managed markers, adopting existing `/socket.io` blocks without duplication. New provisioning emits the same `# >>> frappe socket.io proxy (managed) >>>`/closing markers.

Forward backend Host, `X-Frappe-Site-Name`, HTTPS backend Origin, and `<socket-target>/socket.io`; retain HTTP/1.1 upgrade headers, long timeouts, reflected CORS, Authorization, and polling GET/POST. Local upstream defaults to `http://127.0.0.1:9000` only after verifying listener; remote upstream needs explicit backend target.

## Client and local setup

Keep API/site on backend, socket base on frontend, URL `{socketBaseUrl}/{siteName}`. Send site-routing header and actual `token`/`FlutterDevice` auth; header-auth browsers poll.

Local frontend normally shares Frappe hostname/different port (honor registry exceptions), socket base `<scheme>://<site>:9000`, namespace `/<site>`. Bench common-site developer_mode makes Node auth target webserver port; restart Node after changes. Never enable production developer_mode as a workaround.

## Verification

Helper `--check` reports present and `nginx -t` passes. Polling handshake with frontend Origin returns 200 and that same frontend CORS origin, not backend. Browser has no CORS errors and receives live events; inspect Socket.IO packets, not HTTP statuses alone.
