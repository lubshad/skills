---
name: frappe-deployment
description: Use when creating, changing, or explaining GitHub Actions production deployment for Frappe apps, including goproduction branch promotion and the remote Bench lifecycle.
---

# Frappe Deployment

Use this skill for the Frappe-specific lifecycle inside GitHub Actions production deployments and for the `goproduction` branch-promotion flow that triggers them.

## When To Apply

- Creating or updating a GitHub Actions workflow that deploys a Frappe app
- Creating or updating a Frappe app's `goproduction` helper
- Migrating an existing manual Frappe deployment to GitHub Actions
- Explaining a Frappe production deployment or legacy sync script
- Adjusting remote host, site, SSH key, app path, or migrate/restart flow

## Required Deployment Artifacts

- Keep `.github/workflows/deploy-production.yml` in the Frappe app's actual Git repository.
- Keep `goproduction` in that repository root and make it executable.
- Use a dedicated remote `production` branch as the deployment trigger.
- Maintain a remote `production-backup` branch containing the production ref that existed before the latest promotion.
- Initialize both remote branches from the intended baseline before the first normal promotion.
- Do not create a new app-level `sync.sh`; production source sync belongs inside the GitHub Actions workflow.

## Current Project Defaults

- Masar backend app path: `apps/masar/`
- Masar remote host/site: `masarbackend.conceptiqs.com`
- Exam remote host/site: `mcalfrappe.coreaxissolutions.in`
- Xealth backend app path: `apps/xealth/`
- Xealth remote host/site: `backend.xealth.ca`
- Common remote bench path: `/home/frappe/frappe-bench`
- Common SSH user: `frappe`
- Local legacy scripts may refer to an SSH key named `personal`; never commit that key or any other private key
- Server setup unlocks the `frappe` account when needed and copies the initial root/login user's `authorized_keys` to `/home/frappe/.ssh/authorized_keys`, so deployment scripts can use `ssh frappe@<host>` after setup.

## Production Promotion

- Start from `.agents/skills/github-actions-deployment/reference/frappe-goproduction`.
- Require a clean worktree and a named source branch.
- Refuse promotion from `production` or `production-backup`.
- Fetch and prune `origin` before comparing or updating refs.
- Require `origin/production` so every normal promotion has a recoverable predecessor.
- Back up `origin/production` to `production-backup` before changing production.
- Use `--force-with-lease` for both protected ref updates; never use an unguarded force push.
- Refresh local `production` and `production-backup` refs after successful pushes.
- The helper promotes Git refs only. It must not SSH, rsync, migrate, restart, or duplicate workflow deployment logic.

## Workflow Lifecycle

- Start from `.agents/skills/github-actions-deployment/reference/frappe-production.yml`.
- Check out the pushed production commit and validate all required variables and secrets.
- Configure a temporary step-scoped SSH private key and seed `known_hosts`.
- Validate the remote Bench before syncing.
- Rsync only the app repository into `<bench-dir>/apps/<app-name>` and exclude repository metadata, workflows, local environments, caches, and credential files.
- Install the package with `env/bin/pip install -e apps/<app-name>`.
- Normalize and safely register the app in `sites/apps.txt`; never append with plain `echo` because a missing trailing newline can create malformed app names.
- Run `bench --site <site> install-app <app-name>` only when the app is absent.
- If first-time installation needs Node.js, load NVM when present and add `$HOME/.local/bin` before validating `node` inside that branch only.
- Run `bench --site <site> migrate`, optionally `bench build --app <app-name>`, then `bench restart`.
- Finish with an HTTPS health check and let failure fail the workflow.
- Do not add frontend deployment steps unless explicitly requested.

## GitHub Actions Deployment

- Read `github-actions-deployment.md` alongside this skill for workflow triggers, permissions, concurrency, GitHub environments, secrets, SSH setup, and branch promotion.
- Start from `.agents/skills/github-actions-deployment/reference/frappe-production.yml` when adding a standard production deployment.
- Keep the workflow in the Frappe app's actual Git repository under `.github/workflows/`, including when the app is nested inside a Bench checkout.
- Prefer a `production` branch push trigger and a guarded `workflow_dispatch` retry path.
- Use GitHub secrets for SSH host, user, port, and private key. Never commit the private key or expose it as a job-wide environment variable.
- Rsync only the app repository into `<bench-dir>/apps/<app-name>` and exclude `.git`, `.github`, local environments, caches, and credential files.
- Preserve the standard remote lifecycle: editable package install, safe `sites/apps.txt` registration, conditional first-time app installation, migration, optional build, restart, then an HTTPS health check.
- Use `concurrency` with cancellation disabled so production migrations cannot overlap.
- Use a finite timeout and least-privilege `contents: read` permissions.
- Add the standard `goproduction` helper with every new Frappe production workflow.

## Legacy Manual Sync

- Existing app-level `sync.sh` wrappers and `.agents/scripts/sync_frappe_app.sh` are retained only for legacy maintenance.
- Do not create new wrappers, advertise them as the normal production path, or use them when setting up a new Frappe deployment.
- Do not delete or rewrite an existing legacy sync script unless the user explicitly requests that app's migration or cleanup.
- When asked to explain an existing wrapper, state that GitHub Actions plus `goproduction` is the current production standard.

## Dependency Source Of Truth

- Prefer declaring Python runtime dependencies in the app root `pyproject.toml` under `[project].dependencies`
- Do not add or depend on app-level `requirements.txt` for normal Frappe app deploy flow unless the user explicitly needs a separate legacy or external-tooling requirements file
- When updating an existing deploy script that still uses `pip install -r apps/<app>/requirements.txt`, migrate it to `pip install -e apps/<app>` if the app already has modern packaging metadata

## Safety Rules

- Preserve the existing workflow style when updating an established deployment unless it conflicts with the workflow-only standard
- Prefer safer shell behavior over silent failure
- Do not use `|| true` unless the user explicitly wants best-effort behavior
- Fail clearly if required GitHub secrets, remote branches, or Bench directories are missing
- Keep private keys outside Git, including private repositories; add legacy local key filenames to `.gitignore`
- For freshly provisioned hosts, expect direct `frappe` SSH access to work after `apps/xealth/setup_server.sh` or `.agents/scripts/setup_frappe_server.sh` has completed. If it does not, check whether the account is locked and then check `/home/frappe/.ssh/authorized_keys` ownership and permissions before changing deploy flow.
- Avoid destructive remote commands beyond the intended deploy flow

## Masar-Specific Notes

- `apps/masar/sync.sh` is a legacy backend-only deployment path; do not extend it or include `masarnext` in it.

## Xealth-Specific Notes

- `apps/xealth/setup_server.sh` is a local server-provisioning wrapper, not just an app deploy script.
- Xealth setup must preserve direct `frappe` SSH access by unlocking the account if needed and copying the root/login user's `authorized_keys` to `/home/frappe/.ssh/authorized_keys` during provisioning.
- The Xealth GitHub repo is private; do not rely on remote `bench get-app git@github.com:pentaverse-sa/xealth-backend.git` unless the server has explicit GitHub SSH credentials for the bench user.
- For initial Xealth setup, provision the server/site first, then create a new remote `xealth` app with `bench new-app xealth --no-git` only if `/home/frappe/frappe-bench/apps/xealth` is missing. Do not clone from GitHub or rsync the local checkout as part of server setup.
- After app creation is skipped or completed, install it with `env/bin/pip install -e apps/xealth` only when the package is not already visible to pip, install the app on the site if not already installed, start/reload Bench Redis supervisor services, and run migrate/restart only when package or site app installation changed state.
- Finish Xealth setup by enabling/starting supervisor and nginx, validating/reloading nginx, setting up SSL with Bench/certbot unless `--skip-ssl` is passed, and checking the site through nginx with `Host: backend.xealth.ca` and HTTPS. The SSL step should skip only when both certificate files exist and the bench nginx config already references the certificate; otherwise pipe `y` into `bench setup lets-encrypt` so Bench can overwrite its generated nginx config after cert issuance. Prefer `--ssl-email EMAIL` for Let's Encrypt registration.
- Xealth setup must ensure `/home/frappe/frappe-bench/config/supervisor.conf` is linked into `/etc/supervisor/conf.d/frappe-bench.conf` before `supervisorctl reread/update`; otherwise Bench Redis and worker programs are not loaded even when `supervisor` itself is active.
- Keep reruns idempotent: if `/home/frappe/frappe-bench/apps/xealth` already exists, skip app creation but still check package/site installation status. For future deploy/setup actions, add remote existence or status checks before mutating server state.

## Verification

- Validate workflow and promotion scripts without pushing `production` or contacting the production host as routine verification.
- Run `bash -n goproduction` and verify its clean-worktree and branch guards.
- Verify application package state, site installation, migrations, worker services, and nginx status.
- Verify the target site responds through its intended host and HTTPS configuration.
- Parse or lint GitHub workflow YAML and verify every secret and variable is documented.
- Confirm no private-key files are tracked or included by rsync.
- Confirm no updated guidance recommends creating or using `sync.sh` as the standard production path.
