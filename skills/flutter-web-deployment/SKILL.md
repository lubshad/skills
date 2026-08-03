---
name: flutter-web-deployment
description: Use when changing Flutter web deployment scripts, nginx, certbot, static artifact sync, or GitHub Actions deploy workflows.
---

# Flutter Web Deployment

Use this skill when creating, updating, or explaining Flutter web deployment scripts, nginx setup, certbot setup, static artifact sync, or GitHub Actions deployment workflows.

## Read With

- `flutter-utilities.md` for Flutter web run/build expectations and environment handling.
- `flutter-linting.md` for verification rules.
- `github-actions-deployment.md` for CI/CD workflow, secrets, SSH, and repo-boundary rules.
- `app-connections.md` when hostnames, public URLs, API base URLs, or app/backend mappings matter.
- `flutter-admin-branding.md` if deployment changes web metadata, favicon, PWA manifest, app title, or brand assets.

## File Responsibilities

Keep deployment responsibilities split into separate scripts:

- `deploy.sh`: build and sync Flutter web artifacts.
- `version_increment.sh`: increment `pubspec.yaml` version/build metadata before build.
- `setup_nginx.sh`: install/configure nginx and static site hosting only.
- `setup_certbot.sh`: install/configure certbot certificates only.
- `nginx_configuration`: static nginx template when the app uses a committed template instead of generated config.

Do not run certbot from `setup_nginx.sh`. Do not configure nginx or certbot from GitHub Actions deploy workflows.

## Local Deploy Script

For `deploy.sh`:

- Start with `#!/bin/bash` and `set -euo pipefail`.
- Prefer app-local `deploy_targets.conf` when targets, tenants, entrypoints, hosts, or remote roots vary.
- Validate required tools before use: `flutter`, `ssh`, and `rsync`.
- When creating or materially updating a Flutter deploy script, include an app-local `version_increment.sh` and call it before building unless the deploy is `--deploy-only`.
- Default deploy behavior should increment the build number only; support explicit `--version-bump major|minor|patch|build` and `--no-version-increment`.
- Build with:
  - `flutter pub get`
  - `flutter build web --release -t "$TARGET"`
- Add `--no-tree-shake-icons` only when the existing app needs dynamic icon fonts.
- Sync only `build/web/` to the remote web root with `rsync -avz --delete`.
- Create the remote root before sync and set ownership/permissions after sync.
- Verify the remote deploy by checking `index.html` and counting deployed files.
- Support `--build-only`, `--deploy-only`, `--clean`, and `--help` unless the existing app has a stricter local convention.
- Print the selected target, Flutter entrypoint, remote host, remote path, public host, SSH key, and SSH port before deployment.

## Version Increment Script

For `version_increment.sh`:

- Start with `#!/bin/bash` and `set -euo pipefail`.
- Read the app-local `pubspec.yaml` and update a single `version: x.y.z+n` line.
- Support non-interactive bump modes: `major`, `minor`, `patch`, and `build`.
- Default to `build` when no bump mode is provided.
- Always increment the build number for every successful bump, including major/minor/patch bumps.
- Support `--dry-run` to print the current and next version without editing files.
- Avoid interactive prompts; deployment scripts must be runnable from CI or unattended shells.
- Fail clearly when `pubspec.yaml` is missing or the version line cannot be parsed.

## Nginx Setup Script

For `setup_nginx.sh`:

- Start with `#!/bin/bash` and `set -euo pipefail`.
- Read the same target config as `deploy.sh` where practical.
- Install nginx on Ubuntu/Debian only when it is missing.
- Enable and start nginx.
- Create the remote web root and set `www-data:www-data` ownership with `755` permissions.
- Write the nginx site config to `/etc/nginx/sites-available/<config-name>` and symlink it into `/etc/nginx/sites-enabled/`.
- Run `sudo nginx -t` before reloading nginx.
- Support `--check`, `--test`, `--reload`, `--remove`, and `--help`.
- Never invoke certbot.

The nginx config must include:

- `server_name` for the configured public host.
- `root` pointing to the configured remote web root.
- Flutter SPA fallback: `try_files $uri $uri/ /index.html`.
- Long-cache headers for static assets.
- No-cache handling for `flutter_service_worker.js`.
- Security headers: `X-Frame-Options`, `X-Content-Type-Options`, and `Referrer-Policy`.
- Hidden-file denial with `location ~ /\.`.
- App-specific access and error logs.

## Certbot Setup Script

For `setup_certbot.sh`:

- Start with `#!/bin/bash` and `set -euo pipefail`.
- Read the same target config as `deploy.sh` where practical.
- Require the nginx site config to already exist and pass `sudo nginx -t`.
- Install `certbot` and `python3-certbot-nginx` on Ubuntu/Debian only when missing.
- Issue certificates for the configured public host with the nginx plugin.
- Keep certbot email configurable through `deploy_targets.conf` or a script flag such as `--email`.
- Refuse to issue certificates without a public host and email unless the script explicitly supports `--register-unsafely-without-email`.
- Support `--check`, `--dry-run-renewal`, `--renew`, and `--help`.
- Reload nginx only after certbot succeeds.

## GitHub Actions

For Flutter web deploy workflows:

- Start from `../github-actions-deployment/reference/flutter-web-production.yml`
  when creating a new static web workflow, then apply an app-specific secret prefix.
- Place `.github/workflows/` inside the actual Flutter app Git repository, not the bench root.
- Build in GitHub Actions and deploy only the generated `build/web` artifact.
- Use production branch push triggers plus `workflow_dispatch`.
- Add `concurrency` for production deploys.
- Use a GitHub `environment` with the public URL when available.
- Validate required secrets before build/deploy.
- Read SSH host, user, private key, and optional port from secrets.
- Seed `known_hosts` with `ssh-keyscan`.
- Run `flutter pub get` and `flutter build web --release -t <target>`.
- Verify `build/web/index.html` exists before syncing.
- Sync `build/web/` with `rsync -avz --delete`.
- Verify the remote `index.html` after sync.

Use a consistent secret prefix per app, for example:

- `<APP>_SSH_HOST`
- `<APP>_SSH_USER`
- `<APP>_SSH_PORT`
- `<APP>_SSH_PRIVATE_KEY`

GitHub Actions must not install nginx, run certbot, edit server vhosts, or manage TLS certificates. Those steps belong to the explicit server setup scripts.

## Verification

- Run `flutter analyze` for normal Flutter code changes.
- Run `flutter build web --release -t <target>` when changing deployment, build flags, entrypoints, web metadata, generated assets, or CI build behavior.
- For script-only changes, run `bash -n deploy.sh version_increment.sh setup_nginx.sh setup_certbot.sh` for the scripts that exist.
- Verify `version_increment.sh --dry-run` after creating or changing the version increment script.
- For workflow changes, inspect the actual app Git repo boundary and validate required secrets are documented in the workflow.
