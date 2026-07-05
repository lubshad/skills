#!/usr/bin/env bash
set -euo pipefail

SERVER_HOST="${SERVER_HOST:-}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PORT="${SERVER_PORT:-22}"
SSH_KEY="${SSH_KEY:-personal}"

APP_NAME="${APP_NAME:-}"
SERVER_NAME="${SERVER_NAME:-}"
APP_PORT="${APP_PORT:-}"
SSL_EMAIL="${SSL_EMAIL:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

usage() {
  cat <<EOF
Usage: $0 --host HOST --app-name NAME --server-name NAME --app-port PORT [OPTIONS]

Set up nginx reverse proxy for a Docker-based Docker app.
If --ssl-email is provided, the script also installs Certbot and configures
Let's Encrypt SSL for every domain in --server-name.

Required:
  --host HOST             Remote server host/IP
  --app-name NAME         Nginx site name, e.g. coreaxis
  --server-name NAME      Nginx server_name value, e.g. "example.com www.example.com"
  --app-port PORT         Local Docker host port nginx proxies to, e.g. 3100

Options:
  --ssh-user USER         Remote SSH login user (default: $SERVER_USER)
  --ssh-key PATH          SSH private key path (default: $SSH_KEY)
  --ssh-port PORT         SSH port (default: $SERVER_PORT)
  --ssl-email EMAIL       Enable Let's Encrypt SSL using this email
  --check                 Check remote nginx status and site config
  --test                  Test remote nginx config
  --reload                Reload remote nginx
  --remove                Remove this nginx site config and reload nginx
  -h, --help              Show this help

Examples:
  $0 --host coreaxissolutions.in --app-name coreaxis --server-name "coreaxissolutions.in www.coreaxissolutions.in" --app-port 3100 --ssl-email admin@coreaxissolutions.in --ssh-key personal
  $0 --host coreaxissolutions.in --app-name masarnext --server-name masar.example.com --app-port 3200
EOF
}

fail() {
  print_error "$1"
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

resolve_path() {
  local path_value="$1"

  path_value="${path_value/#\~/$HOME}"

  if [[ "$path_value" = /* ]]; then
    echo "$path_value"
    return
  fi

  if [ -e "$PWD/$path_value" ]; then
    printf '%s/%s\n' "$(cd "$(dirname "$PWD/$path_value")" && pwd)" "$(basename "$path_value")"
    return
  fi

  if [ -e "$BENCH_ROOT/$path_value" ]; then
    printf '%s/%s\n' "$(cd "$(dirname "$BENCH_ROOT/$path_value")" && pwd)" "$(basename "$path_value")"
    return
  fi

  if [ -e "$SCRIPT_DIR/$path_value" ]; then
    printf '%s/%s\n' "$(cd "$(dirname "$SCRIPT_DIR/$path_value")" && pwd)" "$(basename "$path_value")"
    return
  fi

  echo "$path_value"
}

ssh_target() {
  printf '%s@%s' "$SERVER_USER" "$SERVER_HOST"
}

remote_privileged() {
  local command="$1"
  ssh -i "$SSH_KEY" -p "$SERVER_PORT" "$(ssh_target)" \
    "if [ \"\$(id -u)\" -eq 0 ]; then bash -lc $(printf '%q' "$command"); else sudo bash -lc $(printf '%q' "$command"); fi"
}

nginx_config() {
  cat <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_NAME;

    client_max_body_size 25m;

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 60s;
        proxy_connect_timeout 60s;
    }

    access_log /var/log/nginx/${APP_NAME}.access.log;
    error_log /var/log/nginx/${APP_NAME}.error.log;
}
EOF
}

certbot_command() {
  local command email domain
  email="$(printf '%q' "$SSL_EMAIL")"
  command="certbot --nginx --non-interactive --agree-tos --redirect --email $email"

  for domain in $SERVER_NAME; do
    command="$command -d $(printf '%q' "$domain")"
  done

  printf '%s' "$command"
}

CHECK_ONLY=0
RELOAD_ONLY=0
TEST_ONLY=0
REMOVE_CONFIG=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      SERVER_HOST="${2:-}"
      shift 2
      ;;
    --app-name)
      APP_NAME="${2:-}"
      shift 2
      ;;
    --server-name)
      SERVER_NAME="${2:-}"
      shift 2
      ;;
    --app-port)
      APP_PORT="${2:-}"
      shift 2
      ;;
    --ssh-user)
      SERVER_USER="${2:-}"
      shift 2
      ;;
    --ssh-key)
      SSH_KEY="${2:-}"
      shift 2
      ;;
    --ssh-port)
      SERVER_PORT="${2:-}"
      shift 2
      ;;
    --ssl-email)
      SSL_EMAIL="${2:-}"
      shift 2
      ;;
    --check)
      CHECK_ONLY=1
      shift
      ;;
    --test)
      TEST_ONLY=1
      shift
      ;;
    --reload)
      RELOAD_ONLY=1
      shift
      ;;
    --remove)
      REMOVE_CONFIG=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
done

[[ -n "$SERVER_HOST" ]] || fail "--host is required"
[[ -n "$APP_NAME" ]] || fail "--app-name is required"

if [[ "$CHECK_ONLY" -eq 0 && "$RELOAD_ONLY" -eq 0 && "$TEST_ONLY" -eq 0 && "$REMOVE_CONFIG" -eq 0 ]]; then
  [[ -n "$SERVER_NAME" ]] || fail "--server-name is required"
  [[ -n "$APP_PORT" ]] || fail "--app-port is required"
fi

SSH_KEY="$(resolve_path "$SSH_KEY")"
NGINX_CONFIG_FILE="/etc/nginx/sites-available/$APP_NAME"
NGINX_CONFIG_ENABLED="/etc/nginx/sites-enabled/$APP_NAME"

require_command ssh
[[ -f "$SSH_KEY" ]] || fail "SSH key not found: $SSH_KEY"

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  print_status "Checking nginx status for $APP_NAME on $SERVER_HOST..."
  remote_privileged "if command -v nginx >/dev/null 2>&1; then echo 'Nginx is installed'; else echo 'Nginx is not installed'; exit 1; fi; if systemctl is-active --quiet nginx; then echo 'Nginx is running'; else echo 'Nginx is not running'; fi; if [ -f '$NGINX_CONFIG_FILE' ]; then echo 'Config exists: $NGINX_CONFIG_FILE'; else echo 'Config missing'; fi; if [ -L '$NGINX_CONFIG_ENABLED' ]; then echo 'Config enabled: $NGINX_CONFIG_ENABLED'; else echo 'Config not enabled'; fi"
  exit 0
fi

if [[ "$TEST_ONLY" -eq 1 ]]; then
  print_status "Testing nginx configuration on $SERVER_HOST..."
  remote_privileged "nginx -t"
  print_success "Nginx configuration test passed"
  exit 0
fi

if [[ "$RELOAD_ONLY" -eq 1 ]]; then
  print_status "Reloading nginx on $SERVER_HOST..."
  remote_privileged "systemctl reload nginx"
  print_success "Nginx reloaded"
  exit 0
fi

if [[ "$REMOVE_CONFIG" -eq 1 ]]; then
  print_status "Removing nginx config for $APP_NAME on $SERVER_HOST..."
  remote_privileged "rm -f '$NGINX_CONFIG_ENABLED' '$NGINX_CONFIG_FILE' && nginx -t && systemctl reload nginx"
  print_success "Nginx config removed for $APP_NAME"
  exit 0
fi

print_status "Setting up nginx for $SERVER_NAME -> 127.0.0.1:$APP_PORT on $SERVER_HOST..."

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
nginx_config > "$tmp_dir/$APP_NAME.nginx.conf"

remote_privileged "if ! command -v nginx >/dev/null 2>&1; then apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y nginx; fi; systemctl enable nginx; systemctl start nginx; install -d /etc/nginx/sites-available /etc/nginx/sites-enabled"

print_status "Uploading nginx config..."
scp -i "$SSH_KEY" -P "$SERVER_PORT" "$tmp_dir/$APP_NAME.nginx.conf" "$(ssh_target):/tmp/$APP_NAME.nginx.conf"

remote_privileged "mv '/tmp/$APP_NAME.nginx.conf' '$NGINX_CONFIG_FILE' && chown root:root '$NGINX_CONFIG_FILE' && chmod 644 '$NGINX_CONFIG_FILE' && ln -sfn '$NGINX_CONFIG_FILE' '$NGINX_CONFIG_ENABLED' && nginx -t && systemctl reload nginx"

if [[ -n "$SSL_EMAIL" ]]; then
  print_status "Installing Certbot and configuring SSL..."
  remote_privileged "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y certbot python3-certbot-nginx"
  remote_privileged "$(certbot_command) && nginx -t && systemctl reload nginx"
  print_success "SSL configured for: $SERVER_NAME"
else
  print_warning "Only HTTP (port 80) configured. Pass --ssl-email EMAIL to configure SSL automatically."
  print_warning "Example: certbot --nginx $(printf '%s' "$SERVER_NAME" | awk '{for (i=1;i<=NF;i++) printf "-d %s ", $i}')"
fi

print_success "Nginx setup completed for $APP_NAME on $SERVER_HOST"
