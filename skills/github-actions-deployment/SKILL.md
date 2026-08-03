---
name: github-actions-deployment
description: Use when changing GitHub Actions workflows for builds, releases, deployments, or nested-repo deployment flows.
---

# GitHub Actions Deployment

Use this skill when creating or updating GitHub Actions workflows that build, release, or deploy code from this bench or its nested repositories.

## When To Apply

- Adding or editing workflow files under `.github/workflows/`
- Setting up CI/CD for `masarnext` or another deployable project in this workspace
- Creating branch-promotion scripts that trigger GitHub Actions deployments
- Explaining how a GitHub Actions deployment flow should work in this repo

## Repo Boundary Rule

- Identify the actual Git repository before adding a workflow
- If the target project is a nested repo, place `.github/workflows/` inside that nested repo, not at the bench root
- For `next_apps/masarnext`, treat `next_apps/masarnext/` as the Git repo root unless repo inspection shows otherwise

## Workflow Pattern

- Prefer `on.push.branches` for deployment branches and add `workflow_dispatch` for manual retries
- Use `paths` filters only when the release contract intentionally skips deployment for unrelated production-branch changes
- Use `concurrency` for production deploys to prevent overlapping releases
- Use GitHub `environment` for production workflows when the deploy has a stable public URL
- Fail fast on missing required secrets before the deploy step starts
- Set explicit least-privilege workflow permissions, normally `contents: read`
- Set a finite job timeout

## Deployment Rules

- Build in GitHub Actions, not on a developer machine
- Deploy built artifacts, not an unbuilt source tree, unless the platform explicitly requires remote builds
- Prefer `actions/setup-node` with the project’s required Node version and npm cache
- For standalone Next.js deploys, sync only runtime artifacts such as `.next/standalone`, `.next/static`, `public/`, and the runtime launcher
- Keep production environment values server-managed unless the user explicitly asks for a GitHub-managed env strategy
- Do not copy repo `.env.production` to the server when the chosen contract is server-managed env

## SSH Deploy Rules

- Read SSH host, user, key, and optional port from GitHub Secrets
- Keep private keys scoped to only the validation and SSH setup steps; do not expose them as job-wide environment variables
- Write the private key to a temporary file in the runner and lock its permissions
- Seed `known_hosts` with `ssh-keyscan` before `ssh` or `rsync`
- Verify required remote directories and runtime prerequisites before syncing files
- Restart the process manager only after a successful artifact sync
- Run a local remote health check after restart so the workflow fails on a broken deployment

## Pipecat Systemd Deployments

- Read `pipecat-self-hosting.md` alongside this skill.
- Start from `reference/pipecat-systemd-production.yml` and copy `reference/pipecat-goproduction` to the repository root as `goproduction`. Rename generic `PIPECAT_*` secrets and variables only when an app prefix improves clarity.
- Deploy from `production`, keep `workflow_dispatch`, and use the root `goproduction` helper for normal promotion.
- Keep `.env`, dependencies, and the virtual environment server-managed; routine releases sync only `server/bot.py` to the configured runtime directory.
- Upload to a temporary filename, preserve `bot.py.previous`, and atomically replace the runtime file before restart.
- Use `systemctl --no-block restart`; never let an SSH session wait indefinitely for systemd shutdown or startup.
- Bound SSH, rsync, and curl independently. Print phase markers before preflight, upload, restart, local health, and public health.
- Poll both `systemctl is-active` and Pipecat's local `/status` endpoint, then verify the public HTTPS `/status` endpoint.
- On failure, print bounded `systemctl status` and `journalctl -n` output, restore `bot.py.previous`, and restart the service.

The generic Pipecat reference expects these required variables:

- `PIPECAT_REMOTE_PATH`
- `PIPECAT_SERVICE_NAME`
- `PIPECAT_PUBLIC_URL`

It expects these required secrets:

- `PIPECAT_SSH_HOST`
- `PIPECAT_SSH_USER`
- `PIPECAT_SSH_PRIVATE_KEY`

It supports optional `PIPECAT_SSH_PORT`, defaulting to `22`.

## Frappe Application Deployments

- Read `frappe-deployment.md` alongside this skill for Frappe-specific install, migration, build, and restart behavior.
- Start from `reference/frappe-production.yml` and rename its generic `FRAPPE_*` secrets and variables only when an app-specific prefix improves repository clarity.
- Add `goproduction` from `reference/frappe-goproduction` in the Frappe app repository root whenever adding a production workflow.
- Deploy only from a dedicated `production` branch and keep `workflow_dispatch` for guarded retries of the same workflow.
- Initialize remote `production` and `production-backup` branches from the intended baseline before normal promotion begins.
- Use `goproduction` as the normal release entry point: it backs up the current remote production ref, then promotes the current clean branch with `--force-with-lease`.
- Keep deployment operations out of `goproduction`; the production push must be the only action that triggers source sync, migration, restart, and health verification.
- Do not create new Frappe `sync.sh` scripts or document manual rsync as the standard deployment path.
- Sync the checked-out app source into `<bench-dir>/apps/<app-name>`; Frappe editable installs intentionally deploy source rather than a standalone build artifact.
- Exclude repository metadata, workflow files, virtual environments, caches, and local credential files from rsync.
- Install the package with `env/bin/pip install -e apps/<app-name>`, normalize `sites/apps.txt`, install the app only when absent, migrate, optionally build app assets, and restart Bench.
- Keep `bench build --app <app-name>` opt-in unless the app has a concrete asset-build requirement.
- Add `$HOME/.local/bin` to `PATH` for non-interactive SSH sessions and load NVM only when first-time installation needs Node.js.
- Verify the public site after restart and let a failed health check fail the workflow.
- Never commit SSH private keys. Store deployment keys in GitHub environment or repository secrets and keep the private-key value step-scoped.

The generic Frappe reference expects these required variables:

- `FRAPPE_APP_NAME`
- `FRAPPE_SITE`

It expects these required secrets:

- `FRAPPE_SSH_HOST`
- `FRAPPE_SSH_USER`
- `FRAPPE_SSH_PRIVATE_KEY`

It supports optional `FRAPPE_SSH_PORT` and these optional variables:

- `FRAPPE_BENCH_DIR`, defaulting to `/home/frappe/frappe-bench`
- `FRAPPE_PUBLIC_URL`, defaulting to `https://<FRAPPE_SITE>` for the health check
- `FRAPPE_RUN_BUILD`, defaulting to `false`

## Flutter Static Web Deployments

- Read `flutter-web-deployment.md` alongside this skill.
- Start from `reference/flutter-web-production.yml` and rename its generic
  `FLUTTER_WEB_*` secrets and variables to one consistent app prefix.
- Build the configured production entrypoint in Actions and sync only `build/web/`.
- Pass optional compile-time values through step-scoped secrets and
  `--dart-define`; never commit API keys to run scripts.
- Verify local and remote `index.html` before reporting deployment success.
- Do not restart or reload nginx after static artifact sync. Nginx reads the
  replaced files immediately; reload it only after a separately managed config change.
- Keep nginx, certbot, virtual-host, and TLS setup outside the deployment workflow.

The generic Flutter reference expects these required secrets:

- `FLUTTER_WEB_SSH_HOST`
- `FLUTTER_WEB_SSH_USER`
- `FLUTTER_WEB_SSH_PRIVATE_KEY`

It supports optional `FLUTTER_WEB_SSH_PORT`, `FLUTTER_WEB_REMOTE_PATH`, and
`FLUTTER_WEB_GOOGLE_MAPS_API_KEY` secrets plus `FLUTTER_WEB_TARGET` and
`FLUTTER_WEB_PUBLIC_URL` repository variables.

## MasarNext Defaults

- Deployment branch: `production`
- Promotion helper: `next_apps/masarnext/goproduction`
- Workflow location: `next_apps/masarnext/.github/workflows/`
- Host: `masardevelopment.conceptiqs.com`
- Remote dir: `/var/www/masarnext`
- PM2 app: `masarnext`
- Runtime bind: `127.0.0.1:3000`
- Production env file stays on the server at `/var/www/masarnext/.env.production`

## Coordination

- Use `nextjs-deployment.md` together with this skill for `masarnext` deployment work
- Use `app-connections.md` when hostnames, site URLs, or backend/frontend mappings matter
- For Frappe GitHub deployments, combine this skill's workflow and credential rules with `frappe-deployment.md` backend lifecycle rules
- For Pipecat bot production deployments, combine this skill with `pipecat-self-hosting.md`; use its Docker guidance only for an explicit existing Docker deployment

## Verification

- Confirm the workflow is inside the actual deployable Git repository.
- Parse or lint the workflow YAML when tooling is available.
- Run `bash -n goproduction` and verify it refuses dirty worktrees, detached HEAD, `production`, and `production-backup`.
- Verify every referenced secret and variable is documented.
- For Frappe workflows, confirm private keys are step-scoped and local credential files are excluded from source sync.
- Run the same production build command locally when build flags, entrypoints,
  generated assets, or compile-time definitions change.
- Do not push the deployment branch as routine verification.
- Confirm Frappe deployment documentation points to `goproduction` and GitHub Actions rather than a local sync wrapper.
- For Pipecat systemd workflows, confirm restart is non-blocking, every network operation is bounded, failure logs are finite, rollback is present, and local plus public health checks pass.
