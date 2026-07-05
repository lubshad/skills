#!/usr/bin/env bash
set -euo pipefail

SERVER_HOST="${SERVER_HOST:-}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PORT="${SERVER_PORT:-22}"
SSH_KEY="${SSH_KEY:-personal}"
APP_USER="${APP_USER:-dockeruser}"

APP_NAME="${APP_NAME:-}"
IMAGE="${DOCKER_IMAGE:-}"
TAG="${TAG:-latest}"
REMOTE_APP_DIR="${REMOTE_APP_DIR:-}"
CONTAINER_NAME="${CONTAINER_NAME:-}"
HOST_BIND="${HOST_BIND:-127.0.0.1}"
HOST_PORT="${HOST_PORT:-}"
CONTAINER_PORT="${CONTAINER_PORT:-3100}"
ENV_FILE="${ENV_FILE:-.env.production}"
COMPOSE_FILE="${COMPOSE_FILE:-}"

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
Usage: $0 --host HOST --app-name NAME --image IMAGE --host-port PORT [OPTIONS]

Deploy a Docker image as a Docker app on a shared Docker server.
The script creates an app-specific folder under the app user and writes a
standard docker-compose.yml there. The app env file remains server-managed.

Required:
  --host HOST             Remote server host/IP
  --app-name NAME         App folder and compose project name

Required (if --compose-file is not provided):
  --image IMAGE           Docker image repository, e.g. lubshad/coreaxis-next
  --host-port PORT        Host port nginx should proxy to, e.g. 3100

Options:
  --compose-file FILE     Use a custom docker-compose.yml file
  --tag TAG               Docker image tag (default: $TAG)
  --remote-dir PATH       Remote app dir (default: inferred from compose file, or /home/$APP_USER/<app-name>)
  --container-name NAME   Docker container name (default: <app-name>-app)
  --host-bind IP          Host bind IP (default: $HOST_BIND)
  --container-port PORT   Container port (default: $CONTAINER_PORT)
  --env-file FILE         Env file name/path in remote app dir (default: $ENV_FILE)
  --ssh-user USER         Remote setup/sync user (default: $SERVER_USER)
  --ssh-key PATH          SSH private key path (default: $SSH_KEY)
  --ssh-port PORT         SSH port (default: $SERVER_PORT)
  --app-user USER        Remote Linux user for Docker apps (default: $APP_USER)
  -h, --help              Show this help

Examples:
  $0 --host coreaxissolutions.in --app-name coreaxis --image lubshad/coreaxis-next --host-port 3100 --ssh-key personal
  $0 --host coreaxissolutions.in --app-name masarnext --image lubshad/masarnext --host-port 3200 --tag v1
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
    --image)
      IMAGE="${2:-}"
      shift 2
      ;;
    --compose-file)
      COMPOSE_FILE="${2:-}"
      shift 2
      ;;
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    --remote-dir)
      REMOTE_APP_DIR="${2:-}"
      shift 2
      ;;
    --container-name)
      CONTAINER_NAME="${2:-}"
      shift 2
      ;;
    --host-bind)
      HOST_BIND="${2:-}"
      shift 2
      ;;
    --host-port)
      HOST_PORT="${2:-}"
      shift 2
      ;;
    --container-port)
      CONTAINER_PORT="${2:-}"
      shift 2
      ;;
    --env-file)
      ENV_FILE="${2:-}"
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
[[ -n "$APP_NAME" ]] || fail "--app-name is required"

if [[ -z "$COMPOSE_FILE" ]]; then
  [[ -n "$IMAGE" ]] || fail "--image is required (or provide --compose-file)"
  [[ -n "$HOST_PORT" ]] || fail "--host-port is required (or provide --compose-file)"
fi

if [[ -n "$COMPOSE_FILE" ]]; then
  COMPOSE_FILE="$(resolve_path "$COMPOSE_FILE")"
  [[ -f "$COMPOSE_FILE" ]] || fail "Compose file not found: $COMPOSE_FILE"
fi

if [[ -z "$REMOTE_APP_DIR" ]]; then
  if [[ -n "$COMPOSE_FILE" ]]; then
    COMPOSE_DIR="$(dirname "$COMPOSE_FILE")"
    PARENT_DIR_NAME="$(basename "$COMPOSE_DIR")"
    REMOTE_APP_DIR="/home/$APP_USER/$PARENT_DIR_NAME"
  else
    REMOTE_APP_DIR="/home/$APP_USER/$APP_NAME"
  fi
fi

if [[ -z "$CONTAINER_NAME" ]]; then
  CONTAINER_NAME="$APP_NAME-app"
fi

SSH_KEY="$(resolve_path "$SSH_KEY")"
if [[ -n "$IMAGE" ]]; then
  FULL_IMAGE="$IMAGE:$TAG"
else
  FULL_IMAGE="custom-compose-file"
fi

require_command ssh
require_command rsync
[[ -f "$SSH_KEY" ]] || fail "SSH key not found: $SSH_KEY"

if [[ -n "$COMPOSE_FILE" ]]; then
  print_status "Deploying custom compose file $COMPOSE_FILE to $SERVER_HOST:$REMOTE_APP_DIR"
  print_status "Compose project: $APP_NAME"
else
  print_status "Deploying $FULL_IMAGE to $SERVER_HOST:$REMOTE_APP_DIR"
  print_status "Compose project: $APP_NAME"
  print_status "Container: $CONTAINER_NAME"
  print_status "Port: $HOST_BIND:$HOST_PORT -> $CONTAINER_PORT"
fi

print_status "Ensuring remote app directory exists..."
ssh -i "$SSH_KEY" -p "$SERVER_PORT" "$(ssh_target)" \
  APP_USER="$APP_USER" \
  REMOTE_APP_DIR="$REMOTE_APP_DIR" \
  'bash -s' <<'SETUP_EOF'
set -euo pipefail

if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "User $APP_USER does not exist. Run setup_docker_server.sh first." >&2
  exit 1
fi

install -d -m 755 -o "$APP_USER" -g "$APP_USER" "$REMOTE_APP_DIR"
SETUP_EOF

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

if [[ -n "$COMPOSE_FILE" ]]; then
  cp "$COMPOSE_FILE" "$tmp_dir/docker-compose.yml"
else
  cat > "$tmp_dir/docker-compose.yml" <<EOF
services:
  app:
    image: $FULL_IMAGE
    container_name: $CONTAINER_NAME
    restart: unless-stopped
    env_file: $ENV_FILE
    ports:
      - "$HOST_BIND:$HOST_PORT:$CONTAINER_PORT"
EOF
fi

print_status "Uploading docker-compose.yml..."
rsync -az -e "ssh -i $SSH_KEY -p $SERVER_PORT" \
  "$tmp_dir/docker-compose.yml" \
  "${APP_USER}@${SERVER_HOST}:$REMOTE_APP_DIR/docker-compose.yml"

print_status "Pulling image and restarting app..."
ssh -i "$SSH_KEY" -p "$SERVER_PORT" "${APP_USER}@${SERVER_HOST}" \
  COMPOSE_PROJECT_NAME="$APP_NAME" \
  ENV_FILE="$ENV_FILE" \
  REMOTE_APP_DIR="$REMOTE_APP_DIR" \
  'bash -s' <<'DOCKER_EOF'
set -euo pipefail

cd "$REMOTE_APP_DIR"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $REMOTE_APP_DIR/$ENV_FILE. Create it on the server before deploying." >&2
  exit 1
fi

docker compose pull
docker compose up -d
DOCKER_EOF

if [[ -n "$COMPOSE_FILE" ]]; then
  print_success "Deployed $APP_NAME using custom compose file."
else
  print_success "Deployed $FULL_IMAGE as $APP_NAME on $HOST_BIND:$HOST_PORT"
fi
