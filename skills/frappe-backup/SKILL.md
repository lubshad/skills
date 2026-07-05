---
name: frappe-backup
description: Use when changing or explaining Frappe site backup, download, restore, or backup sync scripts.
---

# Frappe Backup

Use this skill for remote Frappe site backup, download, local restore, and site sync scripts in this bench.

## When To Apply

- Creating or updating `sync_server_data.sh` under `sites/*/`
- Using the reusable `.agents/scripts/sync_server_data.sh` to sync any site
- Explaining what an existing site backup/restore script does
- Adjusting remote host, remote site, local site, SSH key, or backup/restore flow

## Reusable Script

Prefer `.agents/scripts/sync_server_data.sh` for any site. It is parameterized, dry-run by default, and works from anywhere inside the bench tree:

```bash
# Dry-run first
.agents/scripts/sync_server_data.sh \
  --remote-host HOST --remote-site SITE --local-site SITE

# Execute
.agents/scripts/sync_server_data.sh --execute \
  --remote-host HOST --remote-site SITE --local-site SITE
```

The script auto-detects bench root by walking up from its location looking for `sites/` + `apps/` markers. Pass `--local-bench` to override.

Key defaults: `--remote-user frappe`, `--remote-bench /home/frappe/frappe-bench`, `--ssh-key <bench_root>/personal`, `--admin-password admin`. MariaDB root password is prompted interactively; pass `--mariadb-root-password` to skip the prompt.

Flags: `--skip-files`, `--skip-backup`, `--ssh-port`, `--remote-user`, `--remote-bench`, `--admin-password`, `--mariadb-root-password`.

**Note:** `scp` uses `-P` (uppercase) for port, unlike `ssh` which uses `-p`. The script handles this.

## Per-Site Scripts (Legacy)

Sync scripts under `sites/*/sync_server_data.sh` (e.g. `luxeo.localhost`, `masar.localhost`) are the older per-site pattern with hardcoded defaults. The reusable script above replaces them for new sites.

### Bench Paths

- From a script under `sites/<site>/`, derive the Frappe bench root with `cd "$SCRIPT_DIR/../.."`, not `cd "$SCRIPT_DIR/.."`
- Use the bench root for local paths such as `$BENCH_ROOT/sites/<local-site>` and `$BENCH_ROOT/sites/backups/<remote-site>`
- Do not build local paths from the `sites/` directory itself, because that creates invalid nested paths like `sites/sites/<site>`

Required local path setup for scripts under `sites/<site>/`:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SSH_KEY="$BENCH_ROOT/personal"
LOCAL_BENCH_PATH="$BENCH_ROOT"
```

### scp vs ssh Port Flag

`ssh` uses `-p` (lowercase) for port, but `scp` uses `-P` (uppercase). The reusable script handles this automatically. For per-site scripts, use `scp -P <port>`.

### Restore Password

For non-interactive use, pass `--mariadb-root-password` to `bench restore`:

```bash
bench --site "$LOCAL_SITE" restore "$LOCAL_DB" --mariadb-root-password "$MARIADB_ROOT_PASSWORD"
```

If omitted, `bench` prompts interactively for the MariaDB root password.

## Current Project Defaults

- Masar local site: `sites/masar.localhost`
- Masar remote host/site: `masarbackend.conceptiqs.com`
- Luxeo local site: `sites/luxeo.localhost`
- Luxeo remote host: `coreaxissolutions.in`
- Luxeo remote site: `luxeo.coreaxissolutions.in`
- Exam remote host/site: `mcalfrappe.coreaxissolutions.in`
- Common remote bench path: `/home/frappe/frappe-bench`
- Common SSH user: `frappe`
- Existing scripts commonly use the SSH key name `personal` from the Frappe bench root

## Script Pattern

For site sync scripts (applies to both reusable and per-site):

- Start with `#!/usr/bin/env bash`
- Prefer `set -euo pipefail`
- Take a remote backup with `bench --site <remote-site> backup`
- Add `--with-files` by default unless the user wants DB-only sync
- Resolve the default SSH key and relative `--ssh-key` values from the Frappe bench root, not the site directory
- Set `LOCAL_BENCH_PATH` to the Frappe bench root, not the parent `sites/` directory
- Download the newest DB backup and optional public/private file archives
- Restore into the local site with `bench --site <local-site> restore`
- Re-extract `public/files` and `private/files` if file archives exist
- Frappe file archives include paths like `./<remote-site>/public/files/...`; extract into the local `files` directories with `tar --strip-components 4` so files land at `$BENCH_ROOT/sites/<local-site>/public/files` and `$BENCH_ROOT/sites/<local-site>/private/files`
- Before extracting file archives, remove stale nested remote-site folders under local `public/` and `private/` to clean up previous incorrect extractions
- Finish with:
  - `bench --site <local-site> migrate`
  - `bench --site <local-site> clear-cache`

Required file restore pattern:

```bash
rm -rf "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/public/files"
rm -rf "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/private/files"
rm -rf "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/public/$REMOTE_SITE"
rm -rf "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/private/$REMOTE_SITE"

mkdir -p "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/public/files"
mkdir -p "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/private/files"

if [[ -n "${LOCAL_PUBLIC:-}" ]]; then
	tar -xf "$LOCAL_PUBLIC" -C "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/public/files/" --strip-components 4
fi

if [[ -n "${LOCAL_PRIVATE:-}" ]]; then
	tar -xf "$LOCAL_PRIVATE" -C "$LOCAL_BENCH_PATH/sites/$LOCAL_SITE/private/files/" --strip-components 4
fi
```

After changing a file restore script, verify uploaded files land directly under:

- `$BENCH_ROOT/sites/<local-site>/public/files/<filename>` for `/files/<filename>` URLs
- `$BENCH_ROOT/sites/<local-site>/private/files/<filename>` for private files

They must not land under nested paths like:

- `$BENCH_ROOT/sites/<local-site>/public/<remote-site>/public/files/...`
- `$BENCH_ROOT/sites/<local-site>/public/files/files/...`

## Safety Rules

- Preserve the existing workflow style when updating a script unless the user asks for a redesign
- Prefer safer shell behavior over silent failure
- Fail clearly if the SSH key, remote backup, or required directories are missing
- Avoid destructive remote commands beyond the intended sync/restore flow
- Prefer making SSH key, remote site, and local site configurable with script flags

## Masar-Specific Notes

- `sites/masar.localhost/sync_server_data.sh` should mirror the `mcal` site sync pattern
- If a key path is ambiguous, prefer making it configurable via `--ssh-key`
