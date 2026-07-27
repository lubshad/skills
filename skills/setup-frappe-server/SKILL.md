---
name: setup-frappe-server
description: Use when setting up or configuring a Frappe server, bench, sites, apps, services, or production server prerequisites.
---

# Setup Frappe Server

Use this skill when creating, adapting, or running a local SSH-based Frappe Bench server setup script for Ubuntu/Debian production-style servers.

## When To Apply

- Creating a script that runs from a local machine and provisions a remote Frappe server over SSH
- Creating the remote `frappe` Linux user, sudo access, and bench directory
- Copying the SSH login user's `authorized_keys` to the remote bench user so the bench user can be accessed directly over SSH
- Setting up an idempotent remote swap file for low-memory servers
- Installing Bench dependencies, configuring MariaDB root access, initializing a bench, creating a site, installing apps, and configuring production nginx/supervisor services
- Explaining or changing `.agents/scripts/setup_frappe_server.sh`
- Explaining or changing app-specific server setup wrappers such as `apps/xealth/setup_server.sh`

## Script

Use `.agents/scripts/setup_frappe_server.sh` from the local machine. The script connects to the remote server over SSH, installs server dependencies, configures MariaDB root access, creates the remote `frappe` Linux user when missing, ensures a remote swap file exists by default, and runs the full Frappe Bench setup remotely.

Before running or adapting it:

1. Confirm the target OS is Ubuntu/Debian and remote root SSH is available.
2. Prefer dry-run first; the script defaults to dry-run and requires `--execute` before making remote changes.
3. Collect or choose these values: host, site name, Administrator password, MariaDB root password, Let's Encrypt email, SSH key/port if needed, swap file settings, bench user, branch, bench path, and app repositories.
4. Run syntax checks after edits:

```bash
bash -n .agents/scripts/setup_frappe_server.sh
```

## Xealth Wrapper

Use `apps/xealth/setup_server.sh` for Xealth server setup.

- Defaults:
  - host/site: `backend.xealth.ca`
  - SSH user: `root`
  - SSH key: `apps/xealth/personal` when present
  - bench path: `/home/frappe/frappe-bench`
- The wrapper calls `.agents/scripts/setup_frappe_server.sh` for OS, MariaDB, swap, Bench, site setup, and production nginx/supervisor setup.
- The shared setup script copies the root/login user's SSH authorized keys to `/home/frappe/.ssh/authorized_keys`, so later operational access can use `ssh frappe@backend.xealth.ca`.
- Do not use remote `bench get-app git@github.com:pentaverse-sa/xealth-backend.git` in the Xealth setup wrapper. That private repo requires GitHub SSH credentials on the server.
- After server setup, the wrapper checks whether `/home/frappe/frappe-bench/apps/xealth` exists. If it exists, it skips app creation but still checks whether the Python package and site app are installed. If it is missing, it creates a new `xealth` app in the remote bench with `bench new-app xealth --no-git`; it does not clone from GitHub or rsync the local checkout during server setup.
- Keep Xealth setup idempotent: do not create the app if `apps/xealth` already exists in the remote bench; do not rerun pip install when the package is already installed; do not rerun `install-app`, migrate, or restart when the app is already installed on the site.
- The wrapper must finish by ensuring production is live: supervisor and nginx enabled/running, nginx config valid/reloaded, SSL configured through Bench/certbot, and the site responding through nginx with the site Host header.
- SSL setup uses Bench's `setup lets-encrypt` flow. Keep it idempotent: install certbot packages only when missing, configure `/etc/letsencrypt/cli.ini` for non-interactive registration, enable `dns_multitenant`, skip the Bench SSL step only when `/etc/letsencrypt/live/<site>/fullchain.pem` and `privkey.pem` exist and the bench nginx config already references the certificate, then verify HTTPS through nginx. `--ssl-email EMAIL` is required. Pipe `y` into `bench setup lets-encrypt` because Bench may still prompt before overwriting `nginx.conf` after cert issuance.
- Keep `--skip-xealth-app` available for setup-only runs.

## Quick Start

Preview a single-site remote setup:

```bash
.agents/scripts/setup_frappe_server.sh \
  --host 203.0.113.10 \
  --site example.com \
  --admin-password 'change-me' \
  --mariadb-root-password 'change-me' \
  --ssl-email admin@example.com \
  --swap-size-gb 4
```

Execute after reviewing the printed SSH commands:

```bash
.agents/scripts/setup_frappe_server.sh \
  --execute \
  --host 203.0.113.10 \
  --site example.com \
  --admin-password 'change-me' \
  --mariadb-root-password 'change-me' \
  --ssl-email admin@example.com
```

Install additional apps:

```bash
.agents/scripts/setup_frappe_server.sh \
  --execute \
  --host 203.0.113.10 \
  --ssh-key ~/.ssh/personal \
  --site example.com \
  --admin-password 'change-me' \
  --mariadb-root-password 'change-me' \
  --ssl-email admin@example.com \
  --app https://github.com/frappe/erpnext \
  --install-app erpnext
```

## Script Notes

- Keep `--execute` explicit. Do not remove dry-run behavior.
- Default initial SSH login is `root`; override with `--ssh-user` only when that remote user has passwordless sudo. After setup, the bench user should also be directly SSH-accessible because the script copies the initial login user's authorized keys to the bench user's `.ssh/authorized_keys`.
- The script creates the remote bench user only when missing, unlocks the account if it is locked so SSH public-key login works, adds it to `sudo` only when it is not already a member, writes `/etc/sudoers.d/frappe` only when the expected passwordless sudo entry is absent or different, and copies the SSH login user's `authorized_keys` to the bench user's `.ssh/authorized_keys` with strict SSH permissions when missing or different.
- The script checks installed APT packages first and only runs `apt-get update`/`apt-get install` when dependencies are missing.
- The script creates `/swapfile` with 4GB by default, activates it, and persists it in `/etc/fstab` only when that swap file is not already active/persisted. Use `--swap-size-gb`, `--swap-file`, or `--skip-swap` to change this behavior.
- The script starts/enables MariaDB and configures the root password from `--mariadb-root-password` before `bench new-site`; if the password already works it skips reconfiguration. Use `--skip-mariadb-config` only when MariaDB is already configured and reachable with that password.
- Default Frappe version is `16`, resolving to the `version-16` branch. Use `--frappe-version 15` for v15, `--frappe-version develop` for develop, or `--frappe-branch` for a custom branch.
- Default Python is `3.14` and default Node is `24`, matching Frappe v16. On Ubuntu releases without a matching APT development package, the script uses uv's managed Python instead. Use `--python-version` to select a compatible alternative for another Frappe branch.
- Before production setup, ensure the uv-installed `frappe-bench` tool Python has `pip` with `python -m ensurepip --upgrade` when needed, install Ansible into that tool environment when missing, and expose `/usr/local/bin/bench` plus `/usr/local/bin/ansible*` symlinks. Bench's production setup invokes nested `bench ...` and `ansible-playbook` subprocesses by command name, so these must be on the system PATH under sudo.
- The script installs `xvfb`, `libfontconfig`, and `wkhtmltopdf` from the APT repositories by default.
- Production service setup uses `sudo /home/<bench-user>/.local/bin/bench setup production <bench-user>`, which configures nginx/supervisor in the standard Bench flow without depending on root's sudo PATH. Run production setup and start/reload supervisor services before `bench migrate`, because Frappe migrate requires `redis_cache` to be running. When checking supervisor state from the bench user, use `sudo supervisorctl status` so the guard sees the root-managed service groups. Enable supervisor/nginx with systemd, set up SSL with `bench setup lets-encrypt <site> --non-interactive`, and verify the site through nginx before reporting success.
- When starting supervisor services, explicitly symlink `<bench-dir>/config/supervisor.conf` into `/etc/supervisor/conf.d/<bench-name>.conf` before `supervisorctl reread/update`; do not assume Bench created the symlink.
- App installation is optional and configured by repeatable `--app` and `--install-app` flags. `bench get-app` is skipped when the target app directory already exists, and `install-app` is skipped when the app is already installed on the site.
- For private local apps that cannot be cloned by the remote server, keep server setup separate from deployment: provision the server first, create or skip the remote app idempotently, and use a deploy/sync script later when local source code should be pushed.
- Prefer guard checks before actions so rerunning setup resumes safely and skips work already completed. Keep every new server mutation behind an existence/status check unless the command is a necessary Frappe reconciliation step such as `bench migrate`; before migrate, ensure Bench Redis services are running.

## Safety

- Never run this script against an existing production host without first confirming backups and reviewing dry-run output.
- Do not hardcode real passwords in a committed copy. Pass secrets at runtime or through a secure shell environment.
- Avoid adding destructive cleanup, database reset, or site drop commands unless the user explicitly asks.

## Verification

- Review dry-run output and backups before executing against a production host.
- Verify Bench, Redis, supervisor, nginx, and the site are healthy after provisioning.
- Verify the bench user has intended SSH access and that no credentials were committed or printed.
