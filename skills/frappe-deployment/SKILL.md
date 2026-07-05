---
name: frappe-deployment
description: Use when changing or explaining Frappe app deployment scripts, deployment sync flow, or production deployment commands.
---

# Frappe Deployment

Use this skill for manual Frappe app deployment sync scripts and for explaining or changing how a Frappe app is deployed in this bench.

## When To Apply

- Creating or updating `sync.sh` for a Frappe app under `apps/*/`
- Explaining what an existing Frappe deploy script does
- Adjusting remote host, site, SSH key, app path, or migrate/restart flow

## Bench Paths

- App deploy scripts live under app roots, for example:
  - `apps/exam/sync.sh`
  - `apps/masar/sync.sh`
- Preferred shared deploy implementation: `scripts/sync_frappe_app.sh`
- New app-level `sync.sh` files should be thin wrappers around `scripts/sync_frappe_app.sh` unless there is a concrete app-specific deployment flow.

## Current Project Defaults

- Masar backend app path: `apps/masar/`
- Masar remote host/site: `masarbackend.conceptiqs.com`
- Exam remote host/site: `mcalfrappe.coreaxissolutions.in`
- Xealth backend app path: `apps/xealth/`
- Xealth remote host/site: `backend.xealth.ca`
- Common remote bench path: `/home/frappe/frappe-bench`
- Common SSH user: `frappe`
- Existing scripts commonly use the SSH key name `personal`
- Server setup unlocks the `frappe` account when needed and copies the initial root/login user's `authorized_keys` to `/home/frappe/.ssh/authorized_keys`, so deployment scripts can use `ssh frappe@<host>` after setup.

## Script Pattern

For Frappe app deploy scripts:

- Start with `#!/bin/bash`
- Prefer `set -euo pipefail`
- Prefer the shared script instead of duplicating deploy logic. App wrappers should resolve the bench root and `exec` the shared script with app-specific defaults, for example:
  `exec "$BENCH_ROOT/scripts/sync_frappe_app.sh" --app <app_name> --server-host <host> --site <site> "$@"`
- Validate required local tools and paths before syncing
- Use `rsync -avz` and exclude `.git`, `__pycache__`, `*.pyc`, `.DS_Store`
- Sync only the app directory unless the user explicitly asks to sync another project
- SSH to the remote bench
- Install the app from its root with `./env/bin/pip install -e apps/<app_name>`
- Register the app in `sites/apps.txt` if it is missing (since rsync bypasses `bench get-app`). Do not use plain `echo "<app_name>" >> sites/apps.txt`; if the file does not end with a newline it can create malformed entries like `existingapp<app_name>`.
- First normalize/repair `sites/apps.txt`, then append with `printf`:
  `touch sites/apps.txt; tmp_apps="$(mktemp)"; while IFS= read -r app_line || [ -n "$app_line" ]; do if [ "$app_line" != "<app_name>" ] && [[ "$app_line" == *"<app_name>" ]]; then prefix="${app_line%<app_name>}"; if [ -n "$prefix" ] && [ -d "apps/$prefix" ]; then printf '%s\n' "$prefix"; printf '%s\n' "<app_name>"; continue; fi; fi; printf '%s\n' "$app_line"; done < sites/apps.txt > "$tmp_apps"; mv "$tmp_apps" sites/apps.txt; if ! grep -Fxq "<app_name>" sites/apps.txt; then printf '%s\n' "<app_name>" >> sites/apps.txt; fi`
- If the app install path creates or validates Frappe `Website Theme` records, validate `node` only inside the first-time `bench install-app` branch; do not block normal sync/migrate deploys for already-installed apps. Frappe compiles website themes through `node generate_bootstrap_theme.js` and first-time install will fail with `[Errno 2] No such file or directory: 'node'` if Node.js is absent from the non-interactive SSH PATH.
- Non-interactive SSH deploy commands may not load NVM or shell profiles even when `node` works in an interactive server session. Before checking `node` in the first-time install branch, source NVM when present and include common local bin paths:
  `if [ -s "$HOME/.nvm/nvm.sh" ]; then . "$HOME/.nvm/nvm.sh"; fi; if [ -d "$HOME/.local/bin" ]; then export PATH="$HOME/.local/bin:$PATH"; fi; command -v node`
- Run:
  - `bench --site <site> install-app <app_name>` (only if not already installed)
  - `bench --site <site> migrate`
  - `bench restart`

## Shared Sync Script

Use `scripts/sync_frappe_app.sh` for standard Frappe app syncs.

Example direct usage:

`scripts/sync_frappe_app.sh --app zenvora --server-host coreaxissolutions.in --site zenvorabackend.coreaxissolutions.in --require-node-on-install`

Mode examples:

- `--mode sync`: rsync app files only
- `--mode install`: run editable package install, normalize `sites/apps.txt`, and run first-time `bench install-app` if needed
- `--mode migrate`: run `bench --site <site> migrate` only
- `--mode build`: run `bench build --app <app_name>` only
- `--mode restart`: run `bench restart` only
- `--mode deploy`: default, runs sync + install + migrate + restart
- `--mode all`: runs sync + install + migrate + build + restart

Supported behavior:

- Resolves local app path from `apps/<app_name>` by default
- Syncs to `<bench_dir>/apps/<app_name>` by default
- Installs the Python package with `env/bin/pip install -e apps/<app_name>`
- Normalizes and repairs `sites/apps.txt` before app installation
- Runs `bench install-app` only when the app is not already installed on the site, unless `--skip-install-app` is passed
- Runs `bench migrate` and `bench restart`, unless skipped with `--skip-migrate` or `--skip-restart`
- Supports `--mode sync|install|migrate|build|restart|deploy|all`; keep `deploy` as the default for backward-compatible app wrappers
- Supports `--dry-run` for remote directory validation and rsync preview
- Supports `--require-node-on-install` for apps whose first install creates `Website Theme` records

Do not add frontend deploy steps unless the user explicitly asks for them.

## Dependency Source Of Truth

- Prefer declaring Python runtime dependencies in the app root `pyproject.toml` under `[project].dependencies`
- Do not add or depend on app-level `requirements.txt` for normal Frappe app deploy flow unless the user explicitly needs a separate legacy or external-tooling requirements file
- When updating an existing deploy script that still uses `pip install -r apps/<app>/requirements.txt`, migrate it to `pip install -e apps/<app>` if the app already has modern packaging metadata

## Safety Rules

- Preserve the existing workflow style when updating a script unless the user asks for a redesign
- Prefer safer shell behavior over silent failure
- Do not use `|| true` unless the user explicitly wants best-effort behavior
- Fail clearly if the SSH key or required directories are missing
- For freshly provisioned hosts, expect direct `frappe` SSH access to work after `apps/xealth/setup_server.sh` or `.agents/scripts/setup_frappe_server.sh` has completed. If it does not, check whether the account is locked and then check `/home/frappe/.ssh/authorized_keys` ownership and permissions before changing deploy flow.
- Avoid destructive remote commands beyond the intended deploy flow

## Masar-Specific Notes

- `apps/masar/sync.sh` is backend-only unless the user explicitly asks to include `masarnext`
- If a key path is ambiguous, prefer making it configurable via `--ssh-key`

## Xealth-Specific Notes

- `apps/xealth/setup_server.sh` is a local server-provisioning wrapper, not just an app deploy script.
- Xealth setup must preserve direct `frappe` SSH access by unlocking the account if needed and copying the root/login user's `authorized_keys` to `/home/frappe/.ssh/authorized_keys` during provisioning.
- The Xealth GitHub repo is private; do not rely on remote `bench get-app git@github.com:pentaverse-sa/xealth-backend.git` unless the server has explicit GitHub SSH credentials for the bench user.
- For initial Xealth setup, provision the server/site first, then create a new remote `xealth` app with `bench new-app xealth --no-git` only if `/home/frappe/frappe-bench/apps/xealth` is missing. Do not clone from GitHub or rsync the local checkout as part of server setup.
- After app creation is skipped or completed, install it with `env/bin/pip install -e apps/xealth` only when the package is not already visible to pip, install the app on the site if not already installed, start/reload Bench Redis supervisor services, and run migrate/restart only when package or site app installation changed state.
- Finish Xealth setup by enabling/starting supervisor and nginx, validating/reloading nginx, setting up SSL with Bench/certbot unless `--skip-ssl` is passed, and checking the site through nginx with `Host: backend.xealth.ca` and HTTPS. The SSL step should skip only when both certificate files exist and the bench nginx config already references the certificate; otherwise pipe `y` into `bench setup lets-encrypt` so Bench can overwrite its generated nginx config after cert issuance. Prefer `--ssl-email EMAIL` for Let's Encrypt registration.
- Xealth setup must ensure `/home/frappe/frappe-bench/config/supervisor.conf` is linked into `/etc/supervisor/conf.d/frappe-bench.conf` before `supervisorctl reread/update`; otherwise Bench Redis and worker programs are not loaded even when `supervisor` itself is active.
- Keep reruns idempotent: if `/home/frappe/frappe-bench/apps/xealth` already exists, skip app creation but still check package/site installation status. For future deploy/setup actions, add remote existence or status checks before mutating server state.
