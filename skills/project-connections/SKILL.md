---
name: project-connections
description: Use when identifying project backend and frontend apps, site URLs, environment references, bench connections, or cross-app configuration details.
---

Reference map for all apps, sites, and their connections in this bench.

## Sites

| Site | Purpose |
|------|---------|
| `sites/mcal.localhost` | Exam management system |
| `sites/masar.localhost` | Masar sports platform |
| `sites/omor.localhost` | Omor ERPNext/Frappe accounting site |
| `sites/sync-dating.localhost` | Sync Dating Frappe app site |
| `sites/usafe-safety.localhost` | Usafe Safety Frappe app site |
| `sites/xealth.localhost` | Xealth Frappe app site |

## Local Frontend Networking Standard

**Crucial Standard:** When developing local frontend web applications (Next.js, Flutter Web, React, etc.) that connect to a local Frappe backend, **you must run the frontend development server using the exact same hostname as the Frappe site**, but on a different port.

**Do not use `localhost` or `127.0.0.1`** as the frontend dev server host. Instead, use the Frappe site's hostname (e.g., `masar.localhost`, `mcal.localhost`).

**Reserved URLs are mandatory:** Always use the local frontend hostname and port assigned in the registry below when running, testing, debugging, previewing, or performing agentic browser work. This includes Playwright and any other browser automation. Do not use a framework default, choose a temporary port, or silently fall back to another port. If the assigned port is occupied, stop the conflicting process or report the conflict. Add every new browser frontend to this registry with a unique port before running it locally.

### Local Frontend URL Registry

| Project surface | Required local URL | Local run command |
|-----------------|--------------------|-------------------|
| Masar web | `http://masar.localhost:3000` | `./run_masar_next.sh` |
| Sync Dating concept 1 | `http://sync-dating.localhost:3001` | Run `npm run dev` in `next_apps/sync_dating/concept-1/` |
| Sync Dating concept 2 | `http://sync-dating.localhost:3002` | Reserved; use this URL when the concept is added |
| Sync Dating concept 3 | `http://sync-dating.localhost:3003` | Reserved; use this URL when the concept is added |
| Usafe Safety admin | `http://usafe-safety.localhost:3004` | Run `npm run dev` in `react_apps/UsafeSafety/` |
| Omor admin | `http://omor.localhost:3005` | Run Flutter web with `--web-hostname omor.localhost --web-port 3005` |
| Masar admin | `http://masar.localhost:8001` | `./run_masar_admin.sh` |
| Zeronic web | `http://zeronic.localhost:8080` | Run `npm run dev` in `react_apps/zeronic/` |
| Exam admin | `http://mcal.localhost:8081` | `./run_lms_admin.sh mcal local --port 8081 -- --web-hostname mcal.localhost` |
| Exam student | `http://mcal.localhost:8082` | `./run_lms_student.sh mcal local --port 8082 -- --web-hostname mcal.localhost` |
| Xealth admin | `http://xealth.localhost:8085` | `./run_xealth_admin.sh --env local` |

Native mobile applications do not have a browser URL. Run them on their assigned simulator or device and keep their API endpoint from the project environment configuration.

**Why this standard exists:**
1. **CORS & Cookies:** Keeps the browser origin strictly aligned with the backend, allowing CORS rules and Frappe's session cookies (`sid`) to function seamlessly without complex proxy configurations.
2. **Socket.IO:** Ensures Frappe's Socket.IO connection origin checks pass.
3. **Consistency:** Aligns the environment across all platforms and sub-projects in the bench.

**Implementation by Platform:**
- **Next.js:** Set the host flag when running the dev server. Update package scripts or `run.sh` to use `npx next dev -H <site>.localhost` (e.g., `npx next dev -H masar.localhost`).
- **Flutter Web:** Pass the web-hostname flag to the run command: `flutter run -d chrome --web-hostname <site>.localhost --web-port <port>`.
- **System Requirements:** Instruct the user to add an `/etc/hosts` entry if they are on a system like macOS that does not auto-resolve `*.localhost` domains (e.g., `sudo sh -c 'echo "127.0.0.1 masar.localhost" >> /etc/hosts'`).

## Masar Project

| Component | Location | Role |
|-----------|----------|------|
| Backend (customizations) | `apps/masar/` | Frappe app with whitelisted APIs, custom fields, patches |
| Web frontend | `next_apps/masarnext/` | Next.js app (App Router, TypeScript, CSS Modules) |
| Admin frontend | `flutter_apps/masar_admin/` | Flutter web admin app |
| API base URL (dev) | `http://masar.localhost:8000` | Set via `MASAR_API_BASE_URL` env var |
| Web local URL | `http://masar.localhost:3000` | Required URL for local runs, tests, and Playwright |
| Admin local URL | `http://masar.localhost:8001` | Run with `run_masar_admin.sh` or `flutter_apps/masar_admin/run.sh`; keeps browser origin aligned with Frappe Socket.IO host |
| Frappe Socket.IO (local) | `http://masar.localhost:9000/masar.localhost` | Local Flutter Socket.IO URL: socket base `http://masar.localhost:9000` plus site namespace `/masar.localhost`. |
| Admin Socket.IO host (prod) | `masaradmin.conceptiqs.com` | Production Flutter Socket.IO connects to `https://masaradmin.conceptiqs.com/masarbackend.conceptiqs.com`; only the socket base host differs from API. |
| Web frontend host (current) | `masardevelopment.conceptiqs.com` | Current hostname used by the web deploy and nginx scripts |
| Backend host (prod) | `masarbackend.conceptiqs.com` | Remote Frappe server used by backend sync scripts |

### Masar Deployment Files

- Legacy backend deploy: `apps/masar/sync.sh`; new Frappe production deployments use GitHub Actions plus `goproduction`
- Backend SSH helper: `apps/masar/sshmain.sh`
- Admin local run: `run_masar_admin.sh` or `flutter_apps/masar_admin/run.sh`
- Web deploy: `next_apps/masarnext/deploy.sh`
- Web nginx setup: `next_apps/masarnext/setup_nginx.sh`
- Web nginx vhost template: `next_apps/masarnext/nginx_configuration`
- Web SSH helper: `next_apps/masarnext/sshmain.sh`

### API Path Pattern
All Frappe API calls follow: `{MASAR_API_BASE_URL}/api/method/masar.api.<method_name>`

### Frappe/Flutter Realtime Requirements

- Masar Admin's realtime client builds the Socket.IO URL as `{socket_base}/{site_namespace}`. Local uses socket base `http://masar.localhost:9000`; production uses socket base `https://masaradmin.conceptiqs.com`. The namespace remains the Frappe API host from app config: local `/masar.localhost`, production `/masarbackend.conceptiqs.com`.
- Masar Admin's preferred realtime path is Socket.IO with `path: /socket.io`, transports `['polling', 'websocket']`, and `Authorization: token <api_key>:<api_secret>` sent from the Flutter client using `extraHeaders`.
- Keep Dio `withCredentials: false` for token-auth Flutter apps unless the task explicitly requires Frappe session-cookie behavior.
- `sites/masar.localhost/site_config.json` must include `allow_cors` for `http://masar.localhost:8001`. If a fallback `sid`/cookie flow is used, also include `allowed_referrers` for that origin.
- `sites/common_site_config.json` must expose `developer_mode: 1` during local bench development so the Socket.IO process rewrites the Flutter origin port (`8001`) to the Frappe webserver port (`8000`) for its internal auth calls.
- Restart `bench start` / Socket.IO after changing common site config; the Node Socket.IO process only reads the config at startup.

## Omor Project

| Component | Location | Role |
|-----------|----------|------|
| Mobile app | `omor/omor_app/` | Flutter customer/vendor app |
| Admin frontend | `omor/omor_admin/` | Flutter web admin app |
| Backend API | `omor/omor_backend/` | Django/DRF API backend |
| ERPNext/Frappe site | `sites/omor.localhost` | Local ERPNext target used by backend integration |
| Mobile local API (non-Android) | `http://0.0.0.0:8000/api/` | Local backend API used by Flutter outside the Android emulator |
| Mobile local API (Android emulator) | `http://10.0.2.2:8000/api/` | Android emulator address for the local backend API |
| Admin local API | `http://localhost:8001/api/` | Local backend API used by the Flutter web admin app |
| Admin local URL | `http://omor.localhost:3005` | Required URL for local runs, tests, and Playwright |
| Mobile local URL | N/A | Native app; run on a simulator or device |
| Backend host (prod) | `https://api.omor.com.sa` | Production Django API host |
| Admin host (prod) | `https://admin.omor.com.sa` | Production admin frontend host |

### Omor ERPNext Integration

- Integration code lives in `omor/omor_backend/erpnext_integration/`.
- Django reads ERPNext connection settings from `ERPNEXT_*` environment variables.
- Backend calls ERPNext/Frappe REST endpoints under the configured `ERPNEXT_BASE_URL`; for local Frappe/ERPNext work, use `http://omor.localhost:8000` unless the environment overrides it.
- Transaction accounting sync is queued through Celery via `sync_erpnext_event`, so ERPNext work should stay backgrounded after local state is persisted.
- Admin accounting endpoints are under `/api/accounting/`, including health, sync event listing, and transaction retry.

## Exam Management Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/exam/exam/` | Frappe app for exam logic |
| Admin frontend | `flutter_apps/lms_admin/` | Flutter app for administrators |
| Student frontend | `flutter_apps/lms_student/` | Flutter app for students taking exams |
| API base URL (dev) | `http://mcal.localhost:8000` | Local MCAL Frappe API host |
| Admin local URL | `http://mcal.localhost:8081` | Required URL for local runs, tests, and Playwright |
| Student local URL | `http://mcal.localhost:8082` | Required URL for local runs, tests, and Playwright |

## Xealth Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/xealth/` | Frappe app |
| Admin frontend | `flutter_apps/xealth_admin/` | Flutter shift management admin panel |
| Frappe site | `sites/xealth.localhost` | Local Xealth target site |
| API base URL (dev) | `http://xealth.localhost:8000` | Local Frappe API host |
| Admin local URL | `http://xealth.localhost:8085` | Required URL for local runs, tests, and Playwright |

## Sync Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/sync_dating/` | Frappe app for Sync Dating customizations and APIs |
| Web frontend | `next_apps/sync_dating/` | Next.js web application |
| Frappe site | `sites/sync-dating.localhost` | Local Sync Dating target site |
| API base URL (dev) | `http://sync-dating.localhost:8000` | Local Frappe API host |
| Concept 1 PWA | `next_apps/sync_dating/concept-1/` | Static installable prototype at `http://sync-dating.localhost:3001`; required URL for local runs, tests, and Playwright |

### Sync Local Frontend

- Run each Next.js development server with hostname `sync-dating.localhost`, not `localhost` or `127.0.0.1`, so future Frappe CORS, session cookies, and Socket.IO share the site hostname.
- Reserve ports `3001`, `3002`, and `3003` for Sync concepts 1, 2, and 3 respectively.

## Zeronic Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/zeronic/` | Frappe app for Zeronic customizations and APIs |
| Web frontend | `react_apps/zeronic/` | Vite/React public Zeronic application |
| Frappe site | `sites/zeronic.localhost` | Local Zeronic target site |
| API base URL (dev) | `http://zeronic.localhost:8000` | Set via `VITE_API_BASE_URL` in the React app's `.env.development` |
| Web frontend URL (dev) | `http://zeronic.localhost:8080` | Run with `npm run dev`; matches the Frappe hostname for CORS, session cookies, and Socket.IO |
| Backend host (prod) | `zeronic.coreaxissolutions.in` | Production Frappe host and site |
| Backend deploy | `apps/zeronic/.github/workflows/deploy-production.yml` | GitHub Actions deploys pushes promoted by `apps/zeronic/goproduction` to the `production` branch |

## Usafe Safety Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/usafe_safety/` | Frappe app for Usafe Safety customizations and APIs |
| Web frontend | `react_apps/UsafeSafety/` | Vite/React public Usafe Safety application |
| Frappe site | `sites/usafe-safety.localhost` | Local Usafe Safety target site |
| API base URL (dev) | `http://usafe-safety.localhost:8000` | Set via `VITE_API_BASE_URL` in the React app's `.env.development` |
| Admin frontend URL (dev) | `http://usafe-safety.localhost:3004` | Run with `npm run dev`; required URL for local runs, tests, and Playwright |

## Environment Config

- Development env files: `.env.development` (Next.js), app config files (Flutter)
- Production env files: `.env.production` (Next.js), separate target files (Flutter)
- Never hardcode site URLs — always read from environment/config.

## Custom Frontend File URLs

- When custom frontends consume Frappe or ERPNext APIs that return file/image paths, use the app's shared URL normalization helper before rendering or storing display URLs.
- Only normalize values that do not already start with `http://` or `https://`; absolute URLs must pass through unchanged.
- Relative or site-rooted values such as `files/image.png`, `/files/image.png`, and `/assets/app/logo.svg` should resolve against the configured backend/Frappe base URL.
- For Flutter apps, put this behavior in a shared core utility such as `FrappeFileUrl.normalize(...)` and reuse it instead of rebuilding URLs inside widgets or feature repositories.
- For Next.js apps, use the shared asset URL helper from `src/lib/apiBaseUrl.ts` instead of duplicating URL logic in feature code.

## Verification

- Verify each configured URL resolves from its intended local or production client environment.
- Verify each browser frontend uses its registry hostname and port for manual tests and Playwright; fail rather than accepting an automatic fallback port.
- Verify no two entries in the local frontend URL registry reserve the same port.
- Verify public, private, and app-asset file URLs use the correct shared normalization path.
- Verify secrets remain in runtime configuration and never enter committed source or client-visible payloads.
