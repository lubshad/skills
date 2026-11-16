---
name: flutter-utilities
description: Use when changing Flutter auth plumbing, splash, WebViews, HTML, environment config, utilities, or launchers.
---

# Flutter Utilities

## Auth and startup

Load environment keys/secrets/base URLs through `flutter_dotenv`/`.env`, not literals. Debug login/signup reads configured credentials automatically and exposes a Fill button.

With Flutter Utils, use `flutter_utils.api.auth.login`, not dummy auth/built-in session login unless required. Persist its returned token pair; managed authentication metadata follows `flutter-networking.md`/`frappe-api-contracts.md`. Validate stored credentials before dashboard and clear auth on 401/Guest.

Splash is the entrypoint: load config, check auth, prefetch common roles/lookups, then react to auth state with dashboard/login navigation. Keep a minimum duration to avoid flashing. Non-sensitive shell preferences persist through the shared preferences helper and survive logout unless explicitly reset; clear auth/session only.

## Launchers

- Web: explicit stable `--web-port`, overridable `--port` where practical. Server-only defaults to `-d web-server`, printing its URL without managing Chrome. Browser flags apply only to Chrome.
- Mobile: support `-d`/`--device` and forward remaining arguments unchanged. Watch mode preserves Flutter's `r`/`R` terminal input; a background child uses `/dev/tty` when available.
- Reruns replace only the selected app's verified Flutter/web process: project PID file, live-command and canonical-cwd checks, graceful bounded stop, then `exec`. Port ownership alone is insufficient; leave unrelated owners alive and report PID/port.
- Local Frappe web uses explicit site-matching `--web-hostname` for Socket.IO origin checks. Masar Admin defaults to `masar.localhost:8001` via `run_masar_admin.sh` or app `run.sh`; backend stays `http://masar.localhost:8000`, realtime on Bench `socketio_port`.
- Print environment, entrypoint, and port before running. Do not start apps for unrelated code checks; use analysis unless asked or run behavior changed.

## Masar realtime

Prefer token auth with Dio `withCredentials: false` and the same `Authorization: token <api_key>:<api_secret>` in socket `extraHeaders`. URLs include site namespace: local `http://masar.localhost:9000/masar.localhost`; production `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`; API stays `https://masarbackend.conceptiqs.com`.

Use `/socket.io`, with polling/websocket transports subject to the browser header-auth restrictions in `flutter-networking.md`. `sid` fallback requires credentials on Dio/socket; use polling-only with `upgrade: false` when websocket cookies are unavailable.

## Web content

Use `flutter_inappwebview` for interactive WebViews and rich-text editors; overlays follow `flutter-dialogs.md` platform-view guards. Display simple HTML through `flutter_widget_from_html_core`, not a WebView.

## Verification

Syntax-check changed launchers using their declared shell. Start twice to check replacement; verify web-server gets no Chrome flags, printed host/port, argument forwarding, and unrelated port-owner preservation.
