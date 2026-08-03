#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SSH_KEY="$SCRIPT_DIR/../../personal"

EXECUTE=0
SSH_HOST=""
SSH_USER="frappe"
SSH_PORT="22"
SSH_KEY=""
BENCH_USER="frappe"
BENCH_DIR="/home/frappe/frappe-bench"
SITE=""
ADMIN_PASSWORD="${SITE_ADMIN_PASSWORD:-}"
MARIADB_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD:-}"
SSL_EMAIL=""
SETUP_SSL=1
ENABLE_SCHEDULER=1
CHECK_DNS=1
INSTALL_APPS=()

if [[ -f "$DEFAULT_SSH_KEY" ]]; then
  SSH_KEY="$DEFAULT_SSH_KEY"
fi

usage() {
  cat <<'USAGE'
Usage:
  add_frappe_site.sh --host HOST --site SITE --ssl-email EMAIL [options]

Create a site in an existing remote production Frappe Bench. The script runs
from the local machine over SSH and defaults to a non-mutating dry run.

Required:
  --host HOST                       Existing server hostname or IP
  --site SITE                       New Frappe site/domain name
  --ssl-email EMAIL                 Let's Encrypt registration email

Credentials:
  --admin-password PASS             New site's Administrator password
  --mariadb-root-password PASS      Existing MariaDB root password

  Credentials can instead be supplied through SITE_ADMIN_PASSWORD and
  MARIADB_ROOT_PASSWORD. During --execute, missing credentials are prompted
  securely when an interactive terminal is available.

Options:
  --execute                         Apply changes; otherwise print the plan
  --install-app APP                 Install an app already in the bench; repeatable
  --ssh-user USER                   Remote SSH user (default: frappe)
  --ssh-key PATH                    SSH private key (default: <bench>/personal when present)
  --ssh-port PORT                   SSH port (default: 22)
  --bench-user USER                 Remote bench owner (default: frappe)
  --bench-dir PATH                  Existing bench path (default: /home/frappe/frappe-bench)
  --skip-ssl                        Do not request a Let's Encrypt certificate
  --skip-scheduler                  Do not enable the scheduler on the new site
  --skip-dns-check                  Skip the local public DNS resolution check
  -h, --help                        Show this help

Examples:
  add_frappe_site.sh --host 203.0.113.10 --site site4.example.com --ssl-email admin@example.com --install-app erpnext

  add_frappe_site.sh --execute --host 203.0.113.10 --site site4.example.com --ssl-email admin@example.com --install-app erpnext
USAGE
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_option_value() {
  local option="$1"
  local value="${2:-}"
  [[ -n "$value" ]] || fail "$option requires a value"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      EXECUTE=1
      shift
      ;;
    --host)
      require_option_value "$1" "${2:-}"
      SSH_HOST="$2"
      shift 2
      ;;
    --site)
      require_option_value "$1" "${2:-}"
      SITE="$2"
      shift 2
      ;;
    --admin-password)
      require_option_value "$1" "${2:-}"
      ADMIN_PASSWORD="$2"
      shift 2
      ;;
    --mariadb-root-password)
      require_option_value "$1" "${2:-}"
      MARIADB_ROOT_PASSWORD="$2"
      shift 2
      ;;
    --ssl-email)
      require_option_value "$1" "${2:-}"
      SSL_EMAIL="$2"
      shift 2
      ;;
    --install-app)
      require_option_value "$1" "${2:-}"
      INSTALL_APPS+=("$2")
      shift 2
      ;;
    --ssh-user)
      require_option_value "$1" "${2:-}"
      SSH_USER="$2"
      shift 2
      ;;
    --ssh-key)
      require_option_value "$1" "${2:-}"
      SSH_KEY="${2/#\~/$HOME}"
      shift 2
      ;;
    --ssh-port)
      require_option_value "$1" "${2:-}"
      SSH_PORT="$2"
      shift 2
      ;;
    --bench-user)
      require_option_value "$1" "${2:-}"
      BENCH_USER="$2"
      shift 2
      ;;
    --bench-dir)
      require_option_value "$1" "${2:-}"
      BENCH_DIR="$2"
      shift 2
      ;;
    --skip-ssl)
      SETUP_SSL=0
      shift
      ;;
    --skip-scheduler)
      ENABLE_SCHEDULER=0
      shift
      ;;
    --skip-dns-check)
      CHECK_DNS=0
      shift
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

[[ -n "$SSH_HOST" ]] || fail "--host is required"
[[ -n "$SITE" ]] || fail "--site is required"
[[ "$SITE" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || fail "--site must be a valid hostname"
[[ "$SSH_PORT" =~ ^[1-9][0-9]*$ ]] || fail "--ssh-port must be a positive integer"

if [[ "$SETUP_SSL" -eq 1 ]]; then
  [[ -n "$SSL_EMAIL" ]] || fail "--ssl-email is required unless --skip-ssl is used"
fi

for app in "${INSTALL_APPS[@]+"${INSTALL_APPS[@]}"}"; do
  [[ "$app" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || fail "invalid app name: $app"
done

command -v ssh >/dev/null 2>&1 || fail "ssh is required"
if [[ -n "$SSH_KEY" && ! -f "$SSH_KEY" ]]; then
  fail "SSH key not found: $SSH_KEY"
fi

if [[ "$SETUP_SSL" -eq 1 && "$CHECK_DNS" -eq 1 ]]; then
  command -v dig >/dev/null 2>&1 || fail "dig is required for the DNS check; use --skip-dns-check to bypass it"
  DNS_RESULT="$(dig +short A "$SITE"; dig +short AAAA "$SITE")"
  [[ -n "$DNS_RESULT" ]] || fail "$SITE does not currently resolve in public DNS"
  printf 'DNS for %s resolves to:\n%s\n' "$SITE" "$DNS_RESULT"
fi

printf 'Add-site plan:\n'
printf '  Server: %s@%s:%s\n' "$SSH_USER" "$SSH_HOST" "$SSH_PORT"
printf '  Bench: %s (owner: %s)\n' "$BENCH_DIR" "$BENCH_USER"
printf '  Site: %s\n' "$SITE"
if [[ "${#INSTALL_APPS[@]}" -gt 0 ]]; then
  printf '  Apps:'
  printf ' %s' "${INSTALL_APPS[@]}"
  printf '\n'
else
  printf '  Apps: Frappe only\n'
fi
printf '  Scheduler: %s\n' "$([[ "$ENABLE_SCHEDULER" -eq 1 ]] && printf enabled || printf skipped)"
printf '  SSL: %s\n' "$([[ "$SETUP_SSL" -eq 1 ]] && printf "Let's Encrypt" || printf skipped)"
printf '  Shared changes: regenerate, validate, and reload nginx; no Supervisor changes\n'

if [[ "$EXECUTE" -eq 0 ]]; then
  printf 'Dry-run only. Re-run with --execute to apply this plan.\n'
  exit 0
fi

if [[ -z "$ADMIN_PASSWORD" ]]; then
  [[ -t 0 ]] || fail "set SITE_ADMIN_PASSWORD or pass --admin-password"
  read -r -s -p "Administrator password for $SITE: " ADMIN_PASSWORD
  printf '\n'
  [[ -n "$ADMIN_PASSWORD" ]] || fail "Administrator password cannot be empty"
fi

if [[ -z "$MARIADB_ROOT_PASSWORD" ]]; then
  [[ -t 0 ]] || fail "set MARIADB_ROOT_PASSWORD or pass --mariadb-root-password"
  read -r -s -p "MariaDB root password: " MARIADB_ROOT_PASSWORD
  printf '\n'
  [[ -n "$MARIADB_ROOT_PASSWORD" ]] || fail "MariaDB root password cannot be empty"
fi

SSH_ARGS=(-p "$SSH_PORT")
if [[ -n "$SSH_KEY" ]]; then
  SSH_ARGS+=(-i "$SSH_KEY")
fi

printf 'Connecting to %s@%s and creating %s.\n' "$SSH_USER" "$SSH_HOST" "$SITE"

{
  printf 'BENCH_USER=%q\n' "$BENCH_USER"
  printf 'BENCH_DIR=%q\n' "$BENCH_DIR"
  printf 'SITE=%q\n' "$SITE"
  printf 'ADMIN_PASSWORD=%q\n' "$ADMIN_PASSWORD"
  printf 'MARIADB_ROOT_PASSWORD=%q\n' "$MARIADB_ROOT_PASSWORD"
  printf 'SSL_EMAIL=%q\n' "$SSL_EMAIL"
  printf 'SETUP_SSL=%q\n' "$SETUP_SSL"
  printf 'ENABLE_SCHEDULER=%q\n' "$ENABLE_SCHEDULER"
  printf 'INSTALL_APPS=('
  for app in "${INSTALL_APPS[@]+"${INSTALL_APPS[@]}"}"; do
    printf '%q ' "$app"
  done
  printf ')\n'
  cat <<'REMOTE_SCRIPT'
set -Eeuo pipefail

SITE_CREATED=0

on_error() {
  local exit_code=$?
  if [[ "$SITE_CREATED" -eq 1 ]]; then
    printf 'Add-site failed after creating %s. The site was left in place for inspection; it was not dropped.\n' "$SITE" >&2
  fi
  exit "$exit_code"
}
trap on_error ERR

run_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo -n "$@"
  fi
}

run_as_bench() {
  if [[ "$(id -un)" == "$BENCH_USER" ]]; then
    (
      cd "$BENCH_DIR"
      export PATH="$HOME/.local/bin:$PATH"
      "$@"
    )
  else
    sudo -n -u "$BENCH_USER" -H bash -lc \
      'cd "$1"; shift; export PATH="$HOME/.local/bin:$PATH"; exec "$@"' \
      bash "$BENCH_DIR" "$@"
  fi
}

restore_nginx() {
  local backup="$1"
  printf 'Restoring nginx configuration from %s.\n' "$backup" >&2
  run_as_bench cp "$backup" "$BENCH_DIR/config/nginx.conf"
  run_root nginx -t
  run_root systemctl reload nginx
}

command -v sudo >/dev/null 2>&1 || [[ "$(id -u)" -eq 0 ]] || {
  printf 'sudo is required for nginx and SSL operations.\n' >&2
  exit 1
}
if [[ "$(id -u)" -ne 0 ]]; then
  sudo -n true || {
    printf 'The SSH user requires passwordless sudo.\n' >&2
    exit 1
  }
fi

id "$BENCH_USER" >/dev/null 2>&1 || {
  printf 'Bench user does not exist: %s\n' "$BENCH_USER" >&2
  exit 1
}
[[ -d "$BENCH_DIR/apps/frappe" && -d "$BENCH_DIR/sites" ]] || {
  printf 'Existing Frappe Bench not found at %s.\n' "$BENCH_DIR" >&2
  exit 1
}
[[ ! -e "$BENCH_DIR/sites/$SITE" ]] || {
  printf 'Site already exists: %s\n' "$SITE" >&2
  exit 1
}
command -v nginx >/dev/null 2>&1 || {
  printf 'nginx is not installed.\n' >&2
  exit 1
}
command -v curl >/dev/null 2>&1 || {
  printf 'curl is not installed.\n' >&2
  exit 1
}
[[ -f "$BENCH_DIR/config/nginx.conf" ]] || {
  printf 'Existing Bench nginx configuration not found at %s/config/nginx.conf.\n' "$BENCH_DIR" >&2
  exit 1
}

run_as_bench bench --version >/dev/null
run_root nginx -t

for app in "${INSTALL_APPS[@]+"${INSTALL_APPS[@]}"}"; do
  [[ -d "$BENCH_DIR/apps/$app" ]] || {
    printf 'Requested app is not present in the bench: %s\n' "$app" >&2
    exit 1
  }
  grep -Fxq "$app" "$BENCH_DIR/sites/apps.txt" || {
    printf 'Requested app is not registered in sites/apps.txt: %s\n' "$app" >&2
    exit 1
  }
done

printf 'Creating site %s.\n' "$SITE"
run_as_bench bench new-site "$SITE" \
  --admin-password "$ADMIN_PASSWORD" \
  --mariadb-root-password "$MARIADB_ROOT_PASSWORD"
SITE_CREATED=1

for app in "${INSTALL_APPS[@]+"${INSTALL_APPS[@]}"}"; do
  printf 'Installing %s on %s.\n' "$app" "$SITE"
  run_as_bench bench --site "$SITE" install-app "$app"
done

run_as_bench bench --site "$SITE" migrate
if [[ "$ENABLE_SCHEDULER" -eq 1 ]]; then
  run_as_bench bench --site "$SITE" enable-scheduler
fi

run_as_bench bench config dns_multitenant on
timestamp="$(date +%Y%m%d%H%M%S)"
nginx_backup="$BENCH_DIR/config/nginx.conf.add-site.$timestamp.bak"
run_as_bench cp "$BENCH_DIR/config/nginx.conf" "$nginx_backup"

if ! printf 'y\n' | run_as_bench bench setup nginx; then
  restore_nginx "$nginx_backup"
  exit 1
fi
if ! run_root nginx -t; then
  restore_nginx "$nginx_backup"
  exit 1
fi
run_root systemctl reload nginx

curl -fsS -H "Host: $SITE" http://127.0.0.1/ >/dev/null || {
  printf 'The new site did not respond through nginx over HTTP.\n' >&2
  exit 1
}

if [[ "$SETUP_SSL" -eq 1 ]]; then
  ssl_nginx_backup="$BENCH_DIR/config/nginx.conf.pre-ssl.$timestamp.bak"
  run_as_bench cp "$BENCH_DIR/config/nginx.conf" "$ssl_nginx_backup"
  printf 'email = %s\nagree-tos = true\nnon-interactive = true\n' "$SSL_EMAIL" | \
    run_root tee /etc/letsencrypt/cli.ini >/dev/null

  if ! printf 'y\ny\n' | run_as_bench sudo -n bench setup lets-encrypt "$SITE" --non-interactive; then
    restore_nginx "$ssl_nginx_backup"
    exit 1
  fi
  if ! run_root nginx -t; then
    restore_nginx "$ssl_nginx_backup"
    exit 1
  fi
  run_root systemctl reload nginx

  [[ -f "/etc/letsencrypt/live/$SITE/fullchain.pem" && -f "/etc/letsencrypt/live/$SITE/privkey.pem" ]] || {
    printf 'Certificate files were not created for %s.\n' "$SITE" >&2
    exit 1
  }
  curl -fsS --resolve "$SITE:443:127.0.0.1" "https://$SITE/" >/dev/null
fi

run_as_bench bench --site "$SITE" list-apps
if [[ "$ENABLE_SCHEDULER" -eq 1 ]]; then
  run_as_bench bench --site "$SITE" scheduler status
fi

trap - ERR
printf 'Site %s was created successfully.\n' "$SITE"
printf 'nginx backup: %s\n' "$nginx_backup"
REMOTE_SCRIPT
} | ssh "${SSH_ARGS[@]}" "$SSH_USER@$SSH_HOST" bash -s

if [[ "$SETUP_SSL" -eq 1 ]]; then
  printf 'Completed add-site flow for https://%s\n' "$SITE"
else
  printf 'Completed add-site flow for http://%s\n' "$SITE"
fi
