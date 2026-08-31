#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BENCH_ROOT="$SCRIPT_DIR"
while [[ "$BENCH_ROOT" != "/" ]]; do
  if [[ -d "$BENCH_ROOT/sites" && -d "$BENCH_ROOT/apps" ]]; then
    break
  fi
  BENCH_ROOT="$(dirname "$BENCH_ROOT")"
done

if [[ "$BENCH_ROOT" == "/" ]]; then
  BENCH_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  printf 'Warning: Could not detect bench root by markers; falling back to %s\n' "$BENCH_ROOT" >&2
fi

EXECUTE=0
REMOTE_USER="frappe"
REMOTE_HOST=""
SSH_PORT="22"
SSH_KEY="$BENCH_ROOT/personal"
REMOTE_BENCH_PATH=""
LOCAL_BENCH_PATH="$BENCH_ROOT"
REMOTE_SITE=""
LOCAL_SITE=""
WITH_FILES=1
SKIP_BACKUP=0
ADMIN_PASSWORD="admin"
MARIADB_ROOT_USERNAME=""
MARIADB_ROOT_PASSWORD=""
RETENTION_DAYS="30"

usage() {
  cat <<'USAGE'
Usage:
  sync_server_data.sh --remote-site SITE --local-site SITE [options]

Sync a remote Frappe site to a local bench site. Downloads the latest remote backup,
restores it locally, and re-extracts public/private files.

Defaults to dry-run. Add --execute to run.

Required:
  --remote-site SITE        Remote site name, e.g. example.com
  --local-site SITE         Local site name, e.g. example.localhost

Options:
  --execute                 Run commands instead of printing them
  --remote-host HOST        Remote server host/IP (default: --remote-site)
  --remote-user USER        Remote SSH login user (default: frappe)
  --ssh-key PATH            SSH private key path (default: <bench_root>/personal)
  --ssh-port PORT           SSH port (default: 22)
  --remote-bench PATH       Remote bench path (default: /home/frappe/frappe-bench)
  --local-bench PATH        Local bench root (default: auto-detected from script location)
  --skip-files              Skip public/private file sync
  --skip-backup             Skip remote backup (use existing latest backup)
  --admin-password PASS     Local admin password for new site (default: admin)
  --mariadb-root-username USER
                            Local MariaDB administrator username (omit to be prompted)
  --mariadb-root-password PASS
                            Local MariaDB administrator password (omit to be prompted)
  --retention-days DAYS     Keep backup files from the last DAYS days (default: 30)
  -h, --help                Show this help

Examples:
  sync_server_data.sh --remote-site luxeo.coreaxissolutions.in --local-site luxeo.localhost
  sync_server_data.sh --execute --remote-site masarbackend.conceptiqs.com --local-site masar.localhost
USAGE
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

quote() {
  printf '%q' "$1"
}

ssh_target() {
  printf '%s@%s' "$REMOTE_USER" "$REMOTE_HOST"
}

ssh_args() {
  local args=(-p "$SSH_PORT")
  if [[ -n "$SSH_KEY" ]]; then
    args+=(-i "$SSH_KEY")
  fi
  printf '%q ' "${args[@]}"
}

remote_shell() {
  local description="$1"
  local command="$2"
  local target
  target="$(ssh_target)"

  if [[ "$EXECUTE" -eq 1 ]]; then
    printf '+ %s\n' "$description"
    local args=(-p "$SSH_PORT")
    if [[ -n "$SSH_KEY" ]]; then
      args+=(-i "$SSH_KEY")
    fi
    ssh "${args[@]}" "$target" "bash -lc $(quote "$command")"
  else
    printf '[dry-run] %s\n' "$description"
    printf '  ssh %s%s %s\n' "$(ssh_args)" "$target" "$command"
  fi
}

remote_capture() {
  local command="$1"
  local args=(-p "$SSH_PORT")
  if [[ -n "$SSH_KEY" ]]; then
    args+=(-i "$SSH_KEY")
  fi
  ssh "${args[@]}" "$(ssh_target)" "bash -lc $(quote "$command")"
}

local_exec() {
  local description="$1"
  local command="$2"

  if [[ "$EXECUTE" -eq 1 ]]; then
    printf '+ %s\n' "$description"
    eval "$command"
  else
    printf '[dry-run] %s\n' "$description"
    printf '  %s\n' "$command"
  fi
}

require_local_tools() {
  command -v ssh >/dev/null 2>&1 || fail "ssh is required on the local machine"
  command -v scp >/dev/null 2>&1 || fail "scp is required on the local machine"
  if [[ -n "$SSH_KEY" && ! -f "$SSH_KEY" ]]; then
    fail "SSH key not found: $SSH_KEY"
  fi
}

ensure_bench_in_path() {
  if ! command -v bench >/dev/null 2>&1; then
    for _d in "$HOME/.local/bin" "$HOME/Library/Python/3.9/bin"; do
      if [[ -x "$_d/bench" ]]; then
        export PATH="$PATH:$_d"
        break
      fi
    done
  fi
  command -v bench >/dev/null 2>&1 || fail "bench not found. Install with: pip3 install frappe-bench"
}

require_values() {
  [[ -n "$REMOTE_SITE" ]] || fail "--remote-site is required"
  [[ -n "$LOCAL_SITE" ]] || fail "--local-site is required"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      EXECUTE=1
      shift
      ;;
    --remote-host)
      REMOTE_HOST="${2:-}"
      shift 2
      ;;
    --remote-user)
      REMOTE_USER="${2:-}"
      shift 2
      ;;
    --ssh-key)
      SSH_KEY="${2:-}"
      SSH_KEY="${SSH_KEY/#\~/$HOME}"
      shift 2
      ;;
    --ssh-port)
      SSH_PORT="${2:-}"
      shift 2
      ;;
    --remote-site)
      REMOTE_SITE="${2:-}"
      shift 2
      ;;
    --local-site)
      LOCAL_SITE="${2:-}"
      shift 2
      ;;
    --remote-bench)
      REMOTE_BENCH_PATH="${2:-}"
      shift 2
      ;;
    --local-bench)
      LOCAL_BENCH_PATH="${2:-}"
      shift 2
      ;;
    --skip-files)
      WITH_FILES=0
      shift
      ;;
    --skip-backup)
      SKIP_BACKUP=1
      shift
      ;;
    --admin-password)
      ADMIN_PASSWORD="${2:-}"
      shift 2
      ;;
    --mariadb-root-password)
      MARIADB_ROOT_PASSWORD="${2:-}"
      shift 2
      ;;
    --mariadb-root-username)
      MARIADB_ROOT_USERNAME="${2:-}"
      shift 2
      ;;
    --retention-days)
      RETENTION_DAYS="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

if [[ -z "$REMOTE_HOST" ]]; then
  REMOTE_HOST="$REMOTE_SITE"
fi

require_values
[[ "$RETENTION_DAYS" =~ ^[1-9][0-9]*$ ]] || fail "--retention-days must be a positive whole number"

if [[ -z "$MARIADB_ROOT_USERNAME" ]]; then
  printf 'MySQL administrative username: ' >&2
  IFS= read -r MARIADB_ROOT_USERNAME || fail "MySQL administrative username is required"
fi
[[ -n "$MARIADB_ROOT_USERNAME" ]] || fail "MySQL administrative username is required"

if [[ -z "$MARIADB_ROOT_PASSWORD" ]]; then
  printf 'MySQL password for %s: ' "$MARIADB_ROOT_USERNAME" >&2
  IFS= read -r -s MARIADB_ROOT_PASSWORD || fail "MySQL administrative password is required"
  printf '\n' >&2
fi
[[ -n "$MARIADB_ROOT_PASSWORD" ]] || fail "MySQL administrative password is required"

require_local_tools

if [[ -z "$REMOTE_BENCH_PATH" ]]; then
  REMOTE_BENCH_PATH="/home/$REMOTE_USER/frappe-bench"
fi

if [[ "$EXECUTE" -eq 1 ]]; then
  ensure_bench_in_path
fi

if [[ ! "$SSH_KEY" = /* ]]; then
  SSH_KEY="$BENCH_ROOT/$SSH_KEY"
fi

if [[ ! -f "$SSH_KEY" ]]; then
  fail "SSH key not found: $SSH_KEY"
fi

LOCAL_BACKUP_DIR="$LOCAL_BENCH_PATH/sites/backups/$REMOTE_SITE"
LOCAL_SITE_DIR="$LOCAL_BENCH_PATH/sites/$LOCAL_SITE"

if [[ "$EXECUTE" -eq 0 ]]; then
  printf 'Dry-run mode. Re-run with --execute to sync.\n\n'
fi

printf '=======================================\n'
printf 'Frappe Site Sync\n'
printf 'Remote: %s@%s (%s)\n' "$REMOTE_USER" "$REMOTE_HOST" "$REMOTE_SITE"
printf 'Local : %s\n' "$LOCAL_SITE"
printf '=======================================\n'

local_exec "Creating backup directory: $LOCAL_BACKUP_DIR" "mkdir -p $(quote "$LOCAL_BACKUP_DIR")"

local_exec "Ensuring bench is running" "
  if ! pgrep -f 'bench start' >/dev/null 2>&1; then
    bench start >/dev/null 2>&1 &
    sleep 5
  fi
"

if [[ $SKIP_BACKUP -eq 0 ]]; then
  REMOTE_BACKUP_CMD="bench --site $(quote "$REMOTE_SITE") backup"
  if [[ $WITH_FILES -eq 1 ]]; then
    REMOTE_BACKUP_CMD="$REMOTE_BACKUP_CMD --with-files"
  fi
  remote_shell "Taking backup on remote: $REMOTE_SITE" "cd $REMOTE_BENCH_PATH && $REMOTE_BACKUP_CMD"
fi

printf '\nFetching latest backup file list from remote...\n'
LATEST_DB=""
LATEST_PUBLIC=""
LATEST_PRIVATE=""

if [[ "$EXECUTE" -eq 1 ]]; then
  LATEST_DB="$(remote_capture "ls -t $REMOTE_BENCH_PATH/sites/$REMOTE_SITE/private/backups/*database.sql.gz 2>/dev/null | head -1")" || true
  LATEST_PUBLIC="$(remote_capture "ls -t $REMOTE_BENCH_PATH/sites/$REMOTE_SITE/private/backups/*-files.tar 2>/dev/null | grep -v 'private-files' | head -1")" || true
  LATEST_PRIVATE="$(remote_capture "ls -t $REMOTE_BENCH_PATH/sites/$REMOTE_SITE/private/backups/*-private-files.tar 2>/dev/null | head -1")" || true
else
  printf '[dry-run] Would fetch latest backup files from remote:\n'
  printf '  ssh %s ls -t %s/sites/%s/private/backups/*database.sql.gz | head -1\n' "$(ssh_args)" "$REMOTE_BENCH_PATH" "$REMOTE_SITE"
  printf '  ssh %s ls -t %s/sites/%s/private/backups/*-files.tar | grep -v private-files | head -1\n' "$(ssh_args)" "$REMOTE_BENCH_PATH" "$REMOTE_SITE"
  printf '  ssh %s ls -t %s/sites/%s/private/backups/*-private-files.tar | head -1\n' "$(ssh_args)" "$REMOTE_BENCH_PATH" "$REMOTE_SITE"
fi

printf 'DB: %s\n' "${LATEST_DB:-NOT FOUND (dry-run)}"
printf 'PUBLIC: %s\n' "${LATEST_PUBLIC:-NOT FOUND (dry-run)}"
printf 'PRIVATE: %s\n' "${LATEST_PRIVATE:-NOT FOUND (dry-run)}"

if [[ "$EXECUTE" -eq 1 && -z "${LATEST_DB:-}" ]]; then
  fail "No DB backup found on remote."
fi

printf '\nDownloading backups...\n'
SCP_ARGS=(-P "$SSH_PORT")
if [[ -n "$SSH_KEY" ]]; then
  SCP_ARGS+=(-i "$SSH_KEY")
fi

if [[ "$EXECUTE" -eq 1 ]]; then
  scp "${SCP_ARGS[@]}" "$REMOTE_USER@$REMOTE_HOST:$LATEST_DB" "$LOCAL_BACKUP_DIR/"

  if [[ -n "${LATEST_PUBLIC:-}" ]]; then
    scp "${SCP_ARGS[@]}" "$REMOTE_USER@$REMOTE_HOST:$LATEST_PUBLIC" "$LOCAL_BACKUP_DIR/"
  fi

  if [[ -n "${LATEST_PRIVATE:-}" ]]; then
    scp "${SCP_ARGS[@]}" "$REMOTE_USER@$REMOTE_HOST:$LATEST_PRIVATE" "$LOCAL_BACKUP_DIR/"
  fi
else
  printf '[dry-run] Would download:\n'
  printf '  scp -P %s -i %s %s@%s:%s %s/\n' "$SSH_PORT" "$SSH_KEY" "$REMOTE_USER" "$REMOTE_HOST" "$LATEST_DB" "$LOCAL_BACKUP_DIR"
  [[ -n "${LATEST_PUBLIC:-}" ]] && printf '  scp -P %s -i %s %s@%s:%s %s/\n' "$SSH_PORT" "$SSH_KEY" "$REMOTE_USER" "$REMOTE_HOST" "$LATEST_PUBLIC" "$LOCAL_BACKUP_DIR"
  [[ -n "${LATEST_PRIVATE:-}" ]] && printf '  scp -P %s -i %s %s@%s:%s %s/\n' "$SSH_PORT" "$SSH_KEY" "$REMOTE_USER" "$REMOTE_HOST" "$LATEST_PRIVATE" "$LOCAL_BACKUP_DIR"
fi

LOCAL_DB=""
LOCAL_PUBLIC=""
LOCAL_PRIVATE=""

if [[ "$EXECUTE" -eq 1 ]]; then
  LOCAL_DB="$(ls -t "$LOCAL_BACKUP_DIR"/*database.sql.gz 2>/dev/null | head -1)" || fail "No local DB backup found in $LOCAL_BACKUP_DIR"
  LOCAL_PUBLIC="$(find "$LOCAL_BACKUP_DIR" -maxdepth 1 -name '*-files.tar' ! -name '*private-files*' -print 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)" || true
  LOCAL_PRIVATE="$(find "$LOCAL_BACKUP_DIR" -maxdepth 1 -name '*-private-files.tar' -print 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)" || true
fi

DATABASE_ADMIN_FLAGS="--mariadb-root-username $(quote "$MARIADB_ROOT_USERNAME")"
if [[ -n "$MARIADB_ROOT_PASSWORD" ]]; then
  DATABASE_ADMIN_FLAGS="$DATABASE_ADMIN_FLAGS --mariadb-root-password $(quote "$MARIADB_ROOT_PASSWORD")"
fi

if [[ ! -d "$LOCAL_SITE_DIR" ]]; then
  local_exec "Creating local site: $LOCAL_SITE" "cd $(quote "$LOCAL_BENCH_PATH") && bench new-site $(quote "$LOCAL_SITE") --admin-password $(quote "$ADMIN_PASSWORD") $DATABASE_ADMIN_FLAGS"
fi

if [[ "$EXECUTE" -eq 1 && -n "${LOCAL_DB:-}" ]]; then
  local_exec "Restoring database to $LOCAL_SITE" "cd $(quote "$LOCAL_BENCH_PATH") && bench --site $(quote "$LOCAL_SITE") restore $(quote "$LOCAL_DB") $DATABASE_ADMIN_FLAGS"
fi

local_exec "Cleaning old files directories" "
  rm -rf $(quote "$LOCAL_SITE_DIR/public/files")
  rm -rf $(quote "$LOCAL_SITE_DIR/private/files")
  rm -rf $(quote "$LOCAL_SITE_DIR/public/$REMOTE_SITE")
  rm -rf $(quote "$LOCAL_SITE_DIR/private/$REMOTE_SITE")
"

local_exec "Creating fresh files directories" "
  mkdir -p $(quote "$LOCAL_SITE_DIR/public/files")
  mkdir -p $(quote "$LOCAL_SITE_DIR/private/files")
"

if [[ $WITH_FILES -eq 1 && -n "${LOCAL_PUBLIC:-}" ]]; then
  local_exec "Extracting public files" "tar -xf $(quote "$LOCAL_PUBLIC") -C $(quote "$LOCAL_SITE_DIR/public/files/") --strip-components 4"
fi

if [[ $WITH_FILES -eq 1 && -n "${LOCAL_PRIVATE:-}" ]]; then
  local_exec "Extracting private files" "tar -xf $(quote "$LOCAL_PRIVATE") -C $(quote "$LOCAL_SITE_DIR/private/files/") --strip-components 4"
fi

local_exec "Running migrate on $LOCAL_SITE" "cd $(quote "$LOCAL_BENCH_PATH") && bench --site $(quote "$LOCAL_SITE") migrate"
local_exec "Clearing cache on $LOCAL_SITE" "cd $(quote "$LOCAL_BENCH_PATH") && bench --site $(quote "$LOCAL_SITE") clear-cache"

# Only prune backups after the selected backup has been restored successfully.
BACKUP_NAMES="\\( -name '*database.sql.gz' -o -name '*-files.tar' -o -name '*-private-files.tar' -o -name '*-site_config_backup.json' \\)"
REMOTE_BACKUP_DIR="$REMOTE_BENCH_PATH/sites/$REMOTE_SITE/private/backups"
REMOTE_CLEANUP_CMD="find $(quote "$REMOTE_BACKUP_DIR") -maxdepth 1 -type f $BACKUP_NAMES ! -newermt $(quote "$RETENTION_DAYS days ago") -delete"
LOCAL_CLEANUP_CMD="find $(quote "$LOCAL_BACKUP_DIR") -maxdepth 1 -type f $BACKUP_NAMES ! -newermt $(quote "$RETENTION_DAYS days ago") -delete"

remote_shell "Removing remote backup files older than $RETENTION_DAYS days" "$REMOTE_CLEANUP_CMD"
local_exec "Removing local backup files older than $RETENTION_DAYS days" "$LOCAL_CLEANUP_CMD"

printf '\nDone: %s -> %s synced successfully\n' "$REMOTE_SITE" "$LOCAL_SITE"
