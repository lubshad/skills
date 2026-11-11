---
name: project-connections
description: Use when identifying project backend and frontend apps, site URLs, environment references, bench connections, or cross-app configuration details.
---

Reference map for all apps, sites, and their connections in this bench.

## Sites

| Site | Purpose |
|------|---------|
| `sites/mcal.localhost` | Exam management system |
| `sites/lms.localhost` | COREAXIS LMS shared backend |
| `sites/masar.localhost` | Masar sports platform |
| `sites/omor.localhost` | Omor ERPNext/Frappe accounting site |
| `sites/sync-dating.localhost` | Sync Dating Frappe app site |
| `sites/usafe-safety.localhost` | Usafe Safety Frappe app site |
| `sites/xealth.localhost` | Xealth Frappe app site |
| `sites/ecommerce.localhost` | ERPNext and Webshop backend for the Local-themed Next.js storefront |

## Local Frontend Networking Standard

**Crucial Standard:** When developing local frontend web applications (Next.js, Flutter Web, React, etc.) that connect to a local Frappe backend, **you must run the frontend development server using the exact same hostname as the Frappe site**, but on a different port. COREAXIS LMS is an explicit exception: use its separate frontend hostnames from the registry and project section below.

**Do not use `localhost` or `127.0.0.1`** as the frontend dev server host. Instead, use the Frappe site's hostname (e.g., `masar.localhost`, `mcal.localhost`).

**Reserved URLs are mandatory:** Always use the local frontend hostname and port assigned in the registry below when running, testing, debugging, previewing, or performing agentic browser work. This includes Playwright and any other browser automation. Do not use a framework default, choose a temporary port, or silently fall back to another port. If the assigned port is occupied, stop the conflicting process or report the conflict. Add every new browser frontend to this registry with a unique port before running it locally.

### Local Frontend URL Registry

| Project surface | Required local URL | Local run command |
|-----------------|--------------------|-------------------|
| Masar web | `http://masar.localhost:3000` | `./run_masar_next.sh` |
| Sync Dating concept 1 | `http://sync-dating.localhost:3001` | Run `npm run dev` in `next_apps/sync-dating/concept-1/` |
| Sync Dating admin | `http://sync-dating.localhost:3006` | Run `npm run dev` in `next_apps/sync-dating/admin/` |
| Sync public web | `http://sync-dating.localhost:3008` | Run `npm run dev` in `next_apps/sync-dating/web/` |
| Ecommerce storefront | `http://ecommerce.localhost:3009` | Run `npm run dev` in `next_apps/ecommerce/` |
| Usafe Safety admin | `http://usafe-safety.localhost:3004` | Run `./run.sh` in `react_apps/usafe_admin/` |
| Usafe Safety super admin | `http://usafe-safety.localhost:3007` | Run `./run.sh` in `react_apps/usafe_super_admin/` |
| Omor admin | `http://omor.localhost:3005` | Run Flutter web with `--web-hostname omor.localhost --web-port 3005` |
| Masar admin | `http://masar.localhost:8001` | `./run_masar_admin.sh` |
| Zeronic web | `http://zeronic.localhost:8080` | Run `npm run dev` in `react_apps/zeronic/` |
| Exam admin | `http://mcal.localhost:8081` | `./run_lms_admin.sh mcal local --port 8081 -- --web-hostname mcal.localhost` |
| Exam student | `http://mcal.localhost:8082` | `./run_lms_student.sh mcal local --port 8082 -- --web-hostname mcal.localhost` |
| COREAXIS LMS admin | `http://lmsadmin.localhost:8083` | Run Flutter web in `flutter_apps/frappe_lms_admin/` with `--web-hostname lmsadmin.localhost --web-port 8083` |
| COREAXIS LMS student | `http://lmsstudent.localhost:8084` | Run Flutter web in `flutter_apps/frappe_lms_student/` with `--web-hostname lmsstudent.localhost --web-port 8084` |
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

- Legacy backend deploy: `apps/masar/sync.sh`; new Frappe production deployments use GitHub Actions plus `deploy`
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

## COREAXIS LMS

COREAXIS LMS consists of a shared Frappe backend and Flutter administrator and student applications. This project mapping is tenant-neutral; production connections and deployment details belong in tenant-specific documentation.

### Components and Local Connections

| Component | Location | Required local URL |
|-----------|----------|--------------------|
| Backend / Frappe Desk | `apps/lms_custom/` | `http://lms.localhost:8000` |
| Admin frontend | `flutter_apps/frappe_lms_admin/` | `http://lmsadmin.localhost:8083` |
| Student frontend | `flutter_apps/frappe_lms_student/` | `http://lmsstudent.localhost:8084` |

These addresses define the required local setup; they do not imply that the site or services are already configured or running.

- The local Frappe site name is `lms.localhost`. Both frontends use `http://lms.localhost:8000` as their API base URL.
- Reserve port `8083` for the admin frontend and `8084` for the student frontend. Use the listed URLs for local runs, manual testing, and browser automation; do not silently fall back to another port.
- Run the admin Flutter web app with `--web-hostname lmsadmin.localhost --web-port 8083` and the student app with `--web-hostname lmsstudent.localhost --web-port 8084`.
- All three hostnames must resolve to the local development machine.
- Frappe CORS must allow `http://lmsadmin.localhost:8083` and `http://lmsstudent.localhost:8084`. If cookie authentication or realtime is used, configure those connections for the separate frontend origins as well.
- The separate frontend hostnames are an explicit exception to this skill's same-hostname convention. This local connection table takes precedence for these two frontends.

### API Configuration References

| Component | Configuration file |
|-----------|--------------------|
| Admin frontend | `flutter_apps/frappe_lms_admin/lib/core/config/app_config.dart` |
| Student frontend | `flutter_apps/frappe_lms_student/lib/core/config/app_config.dart` |

Both Flutter applications support an `API_BASE_URL` override. Read backend URLs from application configuration and use the local backend URL above for this setup.

## Xealth Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/xealth/` | Frappe app |
| Admin frontend | `flutter_apps/xealth_admin/` | Flutter shift management admin panel |
| Employee frontend | `flutter_apps/xealth_employee/` | Flutter employee self-service app (web + Android/iOS) |
| Voice assistant | `pipecat_bots/xealth-voice-assistant/` | Pipecat realtime voice bot (web and Twilio telephony); GitHub: `pentaverse-sa/xealth-voice-assistant` |
| Frappe site | `sites/xealth.localhost` | Local Xealth target site |
| API base URL (dev) | `http://xealth.localhost:8000` | Local Frappe API host |
| Admin local URL | `http://xealth.localhost:8085` | Required URL for local runs, tests, and Playwright |
| Employee local URL | `http://xealth.localhost:8086` | Required URL for local runs, tests, and Playwright |

### Xealth Realtime Hosts

- Both Xealth frontends connect Socket.IO on the frontend's own origin, not the API host. Each frontend vhost reverse-proxies `/socket.io` to the Frappe realtime server; add it with `.agents/scripts/add_socketio_proxy.sh --frontend <frontend-host> --backend <backend-host>`.
- Development: API `backend-dev.xealth.ca`; admin sockets `adminpanel-dev.xealth.ca`; employee sockets `employee-dev.xealth.ca`.
- Production: API `backend.xealth.ca`; admin sockets `adminpanel.xealth.ca`; employee sockets `employee.xealth.ca`.
- The socket namespace stays the Frappe API host (`/backend-dev.xealth.ca` or `/backend.xealth.ca`) because the proxy forwards `X-Frappe-Site-Name` as the backend host.

## Sync Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/sync_dating/` | Frappe app for Sync Dating customizations and APIs |
| Calling backend | `apps/agora_integration/` | Reusable Agora user-to-user audio/video calling Frappe app; installed only on `sync-dating.localhost`; requires `flutter_utils`; `sync_dating` requires it and owns the HTTP wrappers |
| Mobile app | `flutter_apps/syncapp/` | Android/iOS Flutter app (`com.sync.syncapp`) with a dedicated `features/calling/` Agora RTC module |
| Web frontend | `next_apps/sync-dating/` | Next.js frontend directory containing Concept 1 and admin |
| Admin frontend | `next_apps/sync-dating/admin/` | Separate admin UI at `http://sync-dating.localhost:3006` |
| Public website | `next_apps/sync-dating/web/` | One-page Next.js landing, shared Firebase Google login/account creation, and Razorpay recharge at `http://sync-dating.localhost:3008` |
| Public web repository | `https://github.com/lubshad/sync-web` | Private repository; local `origin` uses `git@github.com:lubshad/sync-web.git`, default branch `main` |
| Admin host (dev) | `https://sync-admin.coreaxissolutions.in` | Existing **development** preview, not production; SSH `next@sync-concept-1.coreaxissolutions.in`, directory `$HOME/sync-admin/release`, PM2 `sync-admin`, loopback port `3102` |
| Admin deploy (dev) | `next_apps/sync-dating/admin/.github/workflows/deploy-development.yml` | `./deploy` promotes to `development` with `development-backup`; credentials are `SYNC_ADMIN_DEV_*` inside the `development` environment |
| Admin deploy (prod) | `next_apps/sync-dating/admin/.github/workflows/deploy-production.yml` | `./deploy --prod` promotes to `production`; **no production target is provisioned** and its `SYNC_ADMIN_*` environment credentials remain unconfigured |
| Frappe site | `sites/sync-dating.localhost` | Local Sync Dating target site |
| API base URL (dev) | `http://sync-dating.localhost:8000` | Local Frappe API host |
| Backend host (dev) | `sync-backend.coreaxissolutions.in` | Current **development** host and site; Bench `/home/frappe/frappe-bench`, SSH user `frappe` |
| Backend deploy (dev) | `apps/sync_dating/.github/workflows/deploy-development.yml` | GitHub Actions deploys the `development` branch promoted by `apps/sync_dating/deploy`, using the `development` environment and `FRAPPE_DEV_*` credentials |
| Backend deploy (prod) | `apps/sync_dating/.github/workflows/deploy-production.yml` | Deployed by the `production` branch and the `production` environment; **no production host exists yet** |
| Concept 1 PWA | `next_apps/sync-dating/concept-1/` | Static installable prototype at `http://sync-dating.localhost:3001`; required URL for local runs, tests, and Playwright |

### Sync Agora Calling

- `apps/agora_integration/` is a reusable Agora calling app, currently installed only on the `sync-dating.localhost` site. Its dependency is `flutter_utils`; `sync_dating` declares `required_apps = ["flutter_utils", "agora_integration"]` and provides the HTTP wrappers in `apps/sync_dating/sync_dating/api/calls.py`.
- DocTypes: `Agora Settings` (single; `enabled`, App ID, Password App Certificate, and token/ring/connect/heartbeat timeouts), plus `Agora Call Session`, `Agora Call Participant`, and `Agora Call Event`. A `* * * * *` scheduler task `agora_integration.tasks.expire_calls` expires stale active sessions.
- Store App ID and App Certificate only in `Agora Settings`; never place the certificate in git, Flutter, chat, notification payloads, or logs.
- Flutter calling lives in `flutter_apps/syncapp/lib/features/calling/` (`rtc_service.dart`, `call_signaling.dart`, `calling_scope.dart`). Realtime invitations use standard FCM plus Socket.IO; native handshake authenticates with `Authorization: FlutterDevice <key>:<secret>` against the site namespace `/sync-dating.localhost`, using `SYNC_API_BASE_URL` / `SYNC_SOCKET_BASE_URL` overrides.
- `sync_dating` owns persisted listener availability, user blocking, and member/approved-listener policy; `agora_integration` owns settings, session lifecycle, tokens, events, and notifications.

### Sync Local Frontend

#### Sync Firebase Authentication

- Firebase project: `sync-f4c5c` (project number `324274169006`), shared by the mobile app, backend token verification, and public website. Scope Firebase tools to this project; the tool's active project can belong to another product.
- Public web Firebase app: `Sync Website`, app ID `1:324274169006:web:3717e92976b7f976c1b93f`; auth domain `sync-f4c5c.firebaseapp.com`.
- The public site's local web SDK configuration is in ignored `next_apps/sync-dating/web/.env.local`. Google sign-in is enabled and `sync-dating.localhost` is an authorized Firebase Auth domain. Configure hosted origins separately when hosting is provisioned.
- Website Google login uses `flutter_utils.api.auth.firebase_token_login`, including its configured account-creation and reactivation behavior. No website-specific backend auth endpoint is required. The public website mirrors mobile role/language selection, six member profile steps, and the 13-step listener application with phone OTP and private verification uploads, using the existing Sync APIs. Completed members can recharge; listeners see application/briefing status.

#### Local URLs

- Run each Next.js development server with hostname `sync-dating.localhost`, not `localhost` or `127.0.0.1`, so future Frappe CORS, session cookies, and Socket.IO share the site hostname.
- `sync-backend.coreaxissolutions.in` is the development target, not production. When a production host is provisioned, keep `FRAPPE_DEV_*` on this host and repoint `FRAPPE_*` inside the `production` environment; never let a production workflow fall back to the development host.
- Concept 1 is the only Sync concept in use; reserve port `3001` for it.
- Reserve port `3006` for the separate Sync Dating admin UI.
- Reserve port `3008` for the public Sync website. Its BFF calls the existing shared Firebase login and Sync account/finance APIs, keeping upstream credentials server-controlled.
- The existing hosted admin URL `sync-admin.coreaxissolutions.in` is development; do not add a `-dev` hostname or a second server instance for this setup. Its previous `production` deployment label was historical, not a production-host designation. Keep future production credentials separate, with no fallback to this development server.

## Zeronic Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/zeronic/` | Frappe app for Zeronic customizations and APIs |
| Web frontend | `react_apps/zeronic/` | Vite/React public Zeronic application |
| Frappe site | `sites/zeronic.localhost` | Local Zeronic target site |
| API base URL (dev) | `http://zeronic.localhost:8000` | Set via `VITE_API_BASE_URL` in the React app's `.env.development` |
| Web frontend URL (dev) | `http://zeronic.localhost:8080` | Run with `npm run dev`; matches the Frappe hostname for CORS, session cookies, and Socket.IO |
| Backend host (dev) | `zeronic.coreaxissolutions.in` | Existing hosted development Frappe host/site; SSH user `frappe`, Bench `/home/frappe/frappe-bench` |
| Web host (dev) | `https://zeronic.app` | Existing hosted development React app; SSH user `dockeruser`, port `22`, directory `/var/www/zeronic` |
| Backend deploy (dev) | `apps/zeronic/.github/workflows/deploy-development.yml` | `./deploy` promotes to `development` with `development-backup`; settings belong in the GitHub `development` environment |
| Web deploy (dev) | `react_apps/zeronic/.github/workflows/deploy-development.yml` | Same branch contract; build configuration comes from the GitHub `development` environment |

Zeronic currently has **development hosting only**. Earlier workflow/hostname
descriptions used production labels for these same targets; they do not establish
a production environment. Both helpers are development-only, reject `--prod`, and
leave server actions to GitHub Actions. `goproduction` is disabled. Environment
credential migration and initial branch promotion require separate operator action;
local workflow files do not prove GitHub configuration or a live release is ready.

## Usafe Safety Project

| Component | Location | Role |
|-----------|----------|------|
| Backend | `apps/usafe_safety/` | Frappe app for Usafe Safety customizations and APIs |
| Admin frontend | `react_apps/usafe_admin/` | Vite/React Usafe Safety admin application |
| Super admin frontend | `react_apps/usafe_super_admin/` | Vite/React uSafe platform control panel for uSafe staff (mocked data, HashRouter) |
| Frappe site | `sites/usafe-safety.localhost` | Local Usafe Safety target site |
| API base URL (dev) | `http://usafe-safety.localhost:8000` | Set via `VITE_API_BASE_URL` in the React app's `.env.development` |
| Admin frontend URL (dev) | `http://usafe-safety.localhost:3004` | Run `./run.sh` in `react_apps/usafe_admin/`; required URL for local runs, tests, and Playwright |
| Super admin frontend URL (dev) | `http://usafe-safety.localhost:3007` | Run `./run.sh` in `react_apps/usafe_super_admin/`; required URL for local runs, tests, and Playwright |

## Environment Config

### Ecommerce Storefront

- Frontend: `next_apps/ecommerce/`; backend site: `sites/ecommerce.localhost/`.
- Backend URL: `http://ecommerce.localhost:8000`, configured with server-only `FRAPPE_URL`.
- Public catalog and authenticated shopping-cart operations use the installed Webshop APIs. Runtime session encryption uses private `SESSION_KEY`; browser mutations must match `APP_ORIGIN`.
- Backend extension: `apps/ecommerce_store/`, installed on `ecommerce.localhost` only. Public catalog/detail APIs expose published imported records. Authenticated adapters in `api/checkout.py` use native Webshop carts and quotation requests, with customer-owned addresses and idempotency receipts. Legacy Webshop RPC routes are guarded against ownership or quotation-mode bypass.
- The reference catalog contains non-stock demo items with USD prices in `Local Reference USD`. Source availability is a snapshot, not local inventory. Original `WS-DEMO-*` records are preserved and excluded from the custom storefront catalog.
- `/checkout` is a **quotation-request flow**, enabled by the app-owned `Storefront Checkout Settings` single. Webshop's paid checkout stays disabled; there is no payment gateway, automatic Sales Order or payment collection. ERPNext supplies totals and configured tax/delivery calculations. An administrator command (`ecommerce_store.checkout_setup.prepare`) refreshes the required local USD→INR exchange rate in a background job and exposes durable status in that single.

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
