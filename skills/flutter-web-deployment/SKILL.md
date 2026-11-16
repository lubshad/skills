---
name: flutter-web-deployment
description: Use when changing Flutter web build/sync scripts, nginx, certbot, or deployment workflows.
---

# Flutter Web Deployment

Keep responsibilities separate: `deploy.sh` builds/syncs, `version_increment.sh` bumps, `setup_nginx.sh` hosts, `setup_certbot.sh` manages TLS. Actions deploys generated artifacts; it does not provision nginx/certificates.

Read [the deployment contract](WEB-DEPLOYMENT.md) before modifying these scripts/workflows. It owns flags, exact commands, nginx/security/cache rules, credential handling, environment mappings, and verification.

## Invariants

- Build selected entrypoint, verify `build/web/index.html`, then sync only `build/web/` to the verified root; confirm remote artifacts and public HTTPS separately.
- Web deploy defaults to build-number increment (unlike branch promotion's patch default), with explicit bump/skip/deploy-only controls.
- `deploy` branch promotion remains separate from `deploy.sh`. Migrated dual environments keep distinct targets/config/credentials/concurrency; entrypoint names alone do not prove backend isolation.
- Cross-domain Frappe realtime connects through frontend-origin `/socket.io`, not the backend API origin; use `setup-frappe-realtime.md`.
- Read `github-actions-deployment.md` for CI/security and `project-connections.md` for hosts; branding changes also need `flutter-admin-branding.md`.

## Verification

Run existing-script syntax checks and version dry-run. Build when build flags, entrypoints, metadata/assets, or CI build behavior changes; ordinary code uses analysis. Inspect actual app Git boundaries and documented secrets. Never run deployment merely to validate this skill.
