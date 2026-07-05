#!/usr/bin/env bash
set -euo pipefail

SERVER_HOST="${SERVER_HOST:-}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PORT="${SERVER_PORT:-22}"
SSH_KEY="${SSH_KEY:-personal}"
APP_USER="${APP_USER:-dockeruser}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

usage() {
  cat <<EOF
Usage: $0 --host HOST [OPTIONS]

Set up a Linux server for Docker-based app deployments.
Creates a dedicated app user, installs Docker and rsync, grants Docker access,
and copies SSH authorized_keys to the app user.

Required:
  --host HOST           Remote server host/IP

Options:
  --ssh-user USER       Remote SSH login user (default: $SERVER_USER)
  --ssh-key PATH        SSH private key path (default: $SSH_KEY)
  --ssh-port PORT       SSH port (default: $SERVER_PORT)
  --app-user USER      Remote Linux user for Docker apps (default: $APP_USER)
  -h, --help            Show this help

Examples:
  $0 --host coreaxissolutions.in --ssh-key personal
  $0 --host 203.0.113.10 --ssh-key ~/.ssh/id_rsa --app-user dockeruser
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

copy_authorized_keys_command() {
  cat <<EOF
source_keys="\$HOME/.ssh/authorized_keys";
if [ ! -s "\$source_keys" ] && [ -s /root/.ssh/authorized_keys ]; then
  source_keys="/root/.ssh/authorized_keys";
fi;
if [ -s "\$source_keys" ]; then
  target_home="\$(getent passwd '$APP_USER' | cut -d: -f6)";
  install -d -m 700 -o '$APP_USER' -g '$APP_USER' "\$target_home/.ssh";
  if [ ! -f "\$target_home/.ssh/authorized_keys" ] || ! cmp -s "\$source_keys" "\$target_home/.ssh/authorized_keys"; then
    install -m 600 -o '$APP_USER' -g '$APP_USER' "\$source_keys" "\$target_home/.ssh/authorized_keys";
    printf 'Copied authorized_keys to %s.\n' '$APP_USER';
  else
    printf 'authorized_keys already configured for %s.\n' '$APP_USER';
  fi;
else
  printf 'No authorized_keys found for SSH login user or root; skipping %s SSH key setup.\n' '$APP_USER';
fi
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      SERVER_HOST="${2:-}"
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
    --app-user)
      APP_USER="${2:-}"
      shift 2
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

SSH_KEY="$(resolve_path "$SSH_KEY")"

require_command ssh
[[ -f "$SSH_KEY" ]] || fail "SSH key not found: $SSH_KEY"

print_status "Setting up Docker app server on $(ssh_target)..."
print_status "Using SSH key: $SSH_KEY"
print_status "Docker app user: $APP_USER"

remote_privileged "if ! id '$APP_USER' >/dev/null 2>&1; then useradd --create-home --shell /bin/bash '$APP_USER'; printf 'Created user: %s\n' '$APP_USER'; else printf 'User %s already exists.\n' '$APP_USER'; fi"
remote_privileged "status=\$(passwd -S '$APP_USER' 2>/dev/null | awk '{print \$2}'); if [ \"\$status\" = L ]; then passwd -d '$APP_USER' >/dev/null; printf 'Unlocked %s for SSH public-key login.\n' '$APP_USER'; else printf '%s account is not locked.\n' '$APP_USER'; fi"
remote_privileged "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl rsync"
remote_privileged "if ! command -v docker >/dev/null 2>&1; then curl -fsSL https://get.docker.com | sh; else printf 'Docker already installed.\n'; fi"
remote_privileged "if id -nG '$APP_USER' | tr ' ' '\n' | grep -Fxq docker; then printf '%s is already in docker group.\n' '$APP_USER'; else usermod -aG docker '$APP_USER'; printf 'Added %s to docker group.\n' '$APP_USER'; fi"
remote_privileged "if id -nG '$APP_USER' | tr ' ' '\n' | grep -Fxq sudo; then printf '%s is already in sudo group.\n' '$APP_USER'; else usermod -aG sudo '$APP_USER'; printf 'Added %s to sudo group.\n' '$APP_USER'; fi"
remote_privileged "$(copy_authorized_keys_command)"

print_success "Docker app server setup completed for $SERVER_HOST."
