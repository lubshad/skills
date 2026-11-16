---
name: nextjs-deployment
description: Use when configuring or explaining Next.js deployment, nginx, PM2, runtime environment files, or SSH targets.
---

# Next.js Deployment

Read [the deployment runbook](DEPLOYMENT.md) before script/workflow/runtime changes. It owns exact artifacts, flags, environment-file handling, Masar legacy paths, Node/PM2 bootstrap, and checks. Use `project-connections.md` for hosts and `github-actions-deployment.md` for CI, credentials, and Cloudflare SSH.

## Boundaries

- New services run under the deployment user's resolved `$HOME/<app>` with user-owned PM2 and a loopback port. Provision nginx/TLS/startup separately; preserve Masar's existing `/var/www/masarnext` unless migration is approved.
- Build using the repository-pinned npm, `npm ci`, and standalone output. Sync runtime artifacts, not source or local dotenv files.
- GitHub-scoped variables/secrets generate complete `.env.production` before build. Deploy it atomically with mode 600 before PM2 restart; exclude `.env*` from artifact sync and clean temporary files on every exit. No pre-existing remote env is required for managed first deployment.
- Keep `version_increment.sh` separate, noninteractive, dry-runnable, and called before builds unless deploy-only/skipped.
- Keep nginx reverse proxy/App Router behavior; no static-export conversion or Frappe Bench commands. Remote privileged setup does not require local nginx/sudo.

## Verification

Run existing-script syntax/version dry-run, pinned clean install/build, and the runbook's dual-target env serialization/permissions/ordering/cleanup checks. Deployment itself needs explicit authorization.
