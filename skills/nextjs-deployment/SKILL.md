---
name: nextjs-deployment
description: Use when changing Next.js deployment scripts, nginx setup, PM2 configuration, or production web deploy flow.
---

# Next.js Deployment

Use this skill when explaining, creating, or updating deployment workflows and server setup for Next.js applications in this workspace.

## When To Apply

- Creating or updating a Next.js deployment script or GitHub Actions workflow
- Creating or updating Next.js nginx, PM2, or production runtime setup
- Explaining how a workspace Next.js application is deployed
- Adjusting frontend host, SSH key, app directory, PM2 process, or nginx proxy settings

## Masar Paths

- Web app root: `next_apps/masarnext/`
- Deploy script: `next_apps/masarnext/deploy.sh`
- Version increment script: `next_apps/masarnext/version_increment.sh`
- Nginx setup script: `next_apps/masarnext/setup_nginx.sh`
- Nginx vhost template: `next_apps/masarnext/nginx_configuration`
- SSH helper: `next_apps/masarnext/sshmain.sh`

## New Service Defaults

- Deploy new applications under the SSH user's home directory as `$HOME/<app-name>`.
- Resolve the remote `$HOME` over SSH and use the resulting absolute path. Do not assume the home is `/home/<user>`.
- Run the standalone server and PM2 as the same SSH deployment user so routine artifact sync and restart operations do not require `sudo`.
- Use an app-specific loopback port and proxy it through nginx; nginx does not require the application to live under `/var/www`.
- Keep `.env.production` server-managed at `$HOME/<app-name>/.env.production` unless the project explicitly chooses another environment strategy.
- Install PM2 under `$HOME/.local` when global package installation would require elevated permissions, and include `$HOME/.local/bin` in the remote `PATH`.
- Configure nginx, TLS, and PM2 boot startup separately as one-time privileged server setup.

## Masar Legacy Defaults

- Public frontend host: `masardevelopment.conceptiqs.com`
- Remote SSH user: `root`
- Existing scripts use the SSH key name `personal`
- Remote app directory: `/var/www/masarnext`
- Local Node bind address: `127.0.0.1`
- Local Node port: `3000`
- PM2 process name: `masarnext`
- Remote Node bootstrap: install Node.js 22 automatically if `node`/`npm` are missing

## Deployment Pattern

- Start scripts with `#!/bin/bash`
- Prefer `set -euo pipefail`
- Validate required local tools and paths before building or syncing
- When creating or materially updating a frontend deploy script, include an app-local `version_increment.sh` and call it before building unless the deploy is `--deploy-only`.
- Default deploy behavior should increment the patch or build metadata conservatively according to the project's existing version format; support an explicit skip flag such as `--no-version-increment`
- Build with `npm ci` and `npm run build`; GitHub Actions deployments build in CI, while explicit local deploy scripts build locally
- Pin the npm version in `package.json` through `packageManager` and install that exact version in CI before `npm ci`; do not rely on the npm version bundled with the selected Node runner image.
- Use Next.js standalone output for deployment bundles
- Sync only deployable runtime artifacts to the server
- Sync `.next/standalone`, `.next/static`, `public/`, and the runtime start script
- Auto-install Node.js 22 on the remote host when it is missing
- Run the app behind nginx as a Node process managed by `pm2`
- Start the generated standalone server bound to `127.0.0.1:3000`
- Verify the PM2 process after deploy

## Version Increment Pattern

- Keep version increment logic in `version_increment.sh`, separate from `deploy.sh`.
- Read and update the app-local version source of truth, normally `package.json`.
- Support non-interactive operation suitable for CI and unattended deploys.
- Support `--dry-run` and fail clearly if the version field cannot be parsed.
- Avoid interactive prompts in deploy-time version increments.

## Verification

- For script-only changes, run `bash -n deploy.sh version_increment.sh setup_nginx.sh` for the scripts that exist.
- Verify `version_increment.sh --dry-run` after creating or changing the version increment script.
- Run the clean install and production build with the package-manager version declared by the project.

## Nginx Pattern

- Prefer nginx setup scripts that run from the local app directory and configure the remote server over SSH, matching the deploy script's SSH host/user/key options.
- Use a dedicated remote vhost file in `/etc/nginx/sites-available/`
- Symlink it into remote `/etc/nginx/sites-enabled/`
- Reverse-proxy requests to `http://127.0.0.1:3000`
- Cache `/_next/static/` aggressively
- Keep the main app route proxied so App Router and server rendering continue to work
- Test with remote `nginx -t` before reload
- Support remote status and maintenance flags such as `--check`, `--test`, `--reload`, and `--remove`.
- Keep server name, SSH target, SSH key, nginx site name, and app port configurable through flags and/or environment variables.

## Environment Rules

- Read the backend URL from `.env.production` at runtime.
- Do not hardcode the API base URL inside deployment scripts.
- Production `.env.production` is server-managed by default and stays in the remote application root. New services normally use `$HOME/<app-name>/.env.production`; Masar retains `/var/www/masarnext/.env.production` as an existing project-specific path.
- Do not sync a repo or local `.env.production` to production unless the user explicitly asks for a deploy-managed env strategy.
- If the user explicitly chooses deploy-managed env, validate that the env file is intentional before syncing it.

## Safety Rules

- Preserve the existing workflow style unless the user asks for a redesign
- Fail clearly if the SSH key, env file, or package metadata is missing
- Avoid destructive remote commands beyond the intended deploy flow
- Do not require running local nginx or sudo for scripts intended to configure production nginx; perform privileged nginx work on the remote server through SSH.
- Do not convert this flow into a static export unless the user explicitly asks for that deployment model
- This deploy flow assumes an Ubuntu/Debian-style remote host because Node bootstrap uses `apt`

## Masar-Specific Notes

- This skill is frontend-only and should not run Frappe bench commands
- Use `project-connections.md` for the current frontend and backend host mapping
- If the SSH key path is ambiguous, prefer making it configurable via `--ssh-key`
- Preserve Masar's existing `/var/www/masarnext` path unless a separate migration is explicitly approved.
