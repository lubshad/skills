#!/bin/bash

set -euo pipefail

APP_NAME="${APP_NAME:-}"
SERVER_HOST="${SERVER_HOST:-}"
SERVER_USER="${SERVER_USER:-frappe}"
SERVER_PORT="${SERVER_PORT:-22}"
BENCH_DIR="${BENCH_DIR:-/home/frappe/frappe-bench}"
SITE="${SITE:-}"
REMOTE_APP_DIR="${REMOTE_APP_DIR:-}"
LOCAL_APP_DIR="${LOCAL_APP_DIR:-}"
SSH_KEY="${SSH_KEY:-}"
REQUIRE_NODE_ON_INSTALL="${REQUIRE_NODE_ON_INSTALL:-0}"
MODE="${MODE:-deploy}"
SKIP_INSTALL_APP=0
SKIP_MIGRATE=0
SKIP_RESTART=0
DRY_RUN=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: scripts/sync_frappe_app.sh --app APP --server-host HOST --site SITE [options]

Sync a local Frappe app directory to a remote bench and run deployment steps.

Required:
  --app APP            Frappe app name, matching apps/APP
  --server-host HOST   Remote server host
  --site SITE          Frappe site name

Options:
  --mode MODE                 sync, install, migrate, build, restart, deploy, or all. Default: $MODE
  --server-user USER          Remote SSH user. Default: $SERVER_USER
  --server-port PORT          Remote SSH port. Default: $SERVER_PORT
  --ssh-key PATH              SSH private key. Default: BENCH_ROOT/personal
  --bench-dir PATH            Remote bench directory. Default: $BENCH_DIR
  --local-app-dir PATH        Local app directory. Default: BENCH_ROOT/apps/APP
  --remote-app-dir PATH       Remote app directory. Default: BENCH_DIR/apps/APP
  --require-node-on-install   Require node before first-time bench install-app
  --dry-run                   Validate and show planned changes without changing server files
  --skip-install-app          Skip bench install-app even if the site does not list the app
  --skip-migrate              Skip bench migrate after syncing
  --skip-restart              Skip bench restart after syncing
  -h, --help                  Show this help message

Environment overrides:
  APP_NAME, SERVER_HOST, SERVER_USER, SERVER_PORT, SSH_KEY, BENCH_DIR, SITE,
  LOCAL_APP_DIR, REMOTE_APP_DIR, REQUIRE_NODE_ON_INSTALL, MODE
EOF
}

require_command() {
	local command_name="$1"
	if ! command -v "$command_name" >/dev/null 2>&1; then
		echo "Required command not found: $command_name" >&2
		exit 1
	fi
}

require_path() {
	local path_value="$1"
	local label="$2"
	if [ ! -e "$path_value" ]; then
		echo "$label not found: $path_value" >&2
		exit 1
	fi
}

resolve_path() {
	local path_value="$1"

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

	echo "$path_value"
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--mode)
			MODE="$2"
			shift 2
			;;
		--app)
			APP_NAME="$2"
			shift 2
			;;
		--server-host)
			SERVER_HOST="$2"
			shift 2
			;;
		--server-user)
			SERVER_USER="$2"
			shift 2
			;;
		--server-port)
			SERVER_PORT="$2"
			shift 2
			;;
		--ssh-key)
			SSH_KEY="$2"
			shift 2
			;;
		--bench-dir)
			BENCH_DIR="$2"
			shift 2
			;;
		--site)
			SITE="$2"
			shift 2
			;;
		--local-app-dir)
			LOCAL_APP_DIR="$2"
			shift 2
			;;
		--remote-app-dir)
			REMOTE_APP_DIR="$2"
			shift 2
			;;
		--require-node-on-install)
			REQUIRE_NODE_ON_INSTALL=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
			shift
			;;
		--skip-install-app)
			SKIP_INSTALL_APP=1
			shift
			;;
		--skip-migrate)
			SKIP_MIGRATE=1
			shift
			;;
		--skip-restart)
			SKIP_RESTART=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage >&2
			exit 1
			;;
	esac
done

if [ -z "$APP_NAME" ]; then
	echo "--app is required." >&2
	usage >&2
	exit 1
fi

if [ -z "$SERVER_HOST" ]; then
	echo "--server-host is required." >&2
	usage >&2
	exit 1
fi

if [ -z "$SITE" ]; then
	echo "--site is required." >&2
	usage >&2
	exit 1
fi

DO_SYNC=0
DO_INSTALL=0
DO_MIGRATE=0
DO_BUILD=0
DO_RESTART=0

case "$MODE" in
	sync)
		DO_SYNC=1
		;;
	install)
		DO_INSTALL=1
		;;
	migrate)
		DO_MIGRATE=1
		;;
	build)
		DO_BUILD=1
		;;
	restart)
		DO_RESTART=1
		;;
	deploy)
		DO_SYNC=1
		DO_INSTALL=1
		DO_MIGRATE=1
		DO_RESTART=1
		;;
	all)
		DO_SYNC=1
		DO_INSTALL=1
		DO_MIGRATE=1
		DO_BUILD=1
		DO_RESTART=1
		;;
	*)
		echo "Unknown mode: $MODE" >&2
		usage >&2
		exit 1
		;;
esac

if [ "$SKIP_INSTALL_APP" -eq 1 ]; then
	DO_INSTALL=0
fi

if [ "$SKIP_MIGRATE" -eq 1 ]; then
	DO_MIGRATE=0
fi

if [ "$SKIP_RESTART" -eq 1 ]; then
	DO_RESTART=0
fi

if [ -z "$LOCAL_APP_DIR" ]; then
	LOCAL_APP_DIR="$BENCH_ROOT/apps/$APP_NAME"
fi

if [ -z "$REMOTE_APP_DIR" ]; then
	REMOTE_APP_DIR="$BENCH_DIR/apps/$APP_NAME"
fi

if [ -z "$SSH_KEY" ]; then
	SSH_KEY="$BENCH_ROOT/personal"
fi

LOCAL_APP_DIR="$(resolve_path "$LOCAL_APP_DIR")"
SSH_KEY="$(resolve_path "$SSH_KEY")"
SERVER="$SERVER_USER@$SERVER_HOST"
SSH_OPTIONS=(-i "$SSH_KEY" -p "$SERVER_PORT" -o BatchMode=yes -o ConnectTimeout=15)
RSYNC_RSH="ssh -i $SSH_KEY -p $SERVER_PORT -o BatchMode=yes -o ConnectTimeout=15"

echo "Validating local setup..."
require_command rsync
require_command ssh
require_path "$SSH_KEY" "SSH identity file"
require_path "$LOCAL_APP_DIR" "Local app directory"
require_path "$LOCAL_APP_DIR/pyproject.toml" "App pyproject.toml"

echo "App:        $APP_NAME"
echo "Mode:       $MODE"
echo "Server:     $SERVER"
echo "Site:       $SITE"
echo "Bench:      $BENCH_DIR"
echo "Local app:  $LOCAL_APP_DIR"
echo "Remote app: $REMOTE_APP_DIR"
echo "SSH key:    $SSH_KEY"

if [ "$DRY_RUN" -eq 1 ]; then
	echo "Dry run enabled. No remote files or bench state will be changed."
	echo "Checking remote bench directory..."
	ssh "${SSH_OPTIONS[@]}" "$SERVER" "test -d '$BENCH_DIR'"

	if [ "$DO_SYNC" -eq 1 ]; then
		echo "Previewing rsync changes..."
		rsync -avzn --delete \
			--exclude '.git' \
			--exclude '__pycache__' \
			--exclude '*.pyc' \
			--exclude '.DS_Store' \
			--exclude '.pytest_cache' \
			--exclude '.ruff_cache' \
			--exclude '*.egg-info' \
			--exclude 'node_modules' \
			-e "$RSYNC_RSH" \
			"$LOCAL_APP_DIR/" "$SERVER:$REMOTE_APP_DIR/"
	fi

	cat <<EOF
Dry run completed. Mode "$MODE" would run these steps:
  sync app files:            $DO_SYNC
  install package/app:       $DO_INSTALL
  migrate site:              $DO_MIGRATE
  build app assets:          $DO_BUILD
  restart bench:             $DO_RESTART
  cd "$BENCH_DIR"
EOF
	exit 0
fi

if [ "$DO_SYNC" -eq 1 ]; then
	echo "Ensuring remote app directory exists..."
	ssh "${SSH_OPTIONS[@]}" "$SERVER" <<EOF
set -euo pipefail

if [ ! -d "$BENCH_DIR" ]; then
	echo "Bench directory not found: $BENCH_DIR" >&2
	exit 1
fi

mkdir -p "$REMOTE_APP_DIR"
EOF

	echo "Syncing $APP_NAME to $SERVER:$REMOTE_APP_DIR ..."
		rsync -avz --delete \
		--exclude '.git' \
		--exclude '__pycache__' \
		--exclude '*.pyc' \
		--exclude '.DS_Store' \
		--exclude '.pytest_cache' \
		--exclude '.ruff_cache' \
		--exclude '*.egg-info' \
		--exclude 'node_modules' \
		-e "$RSYNC_RSH" \
		"$LOCAL_APP_DIR/" "$SERVER:$REMOTE_APP_DIR/"
fi

if [ "$DO_INSTALL" -eq 0 ] && [ "$DO_MIGRATE" -eq 0 ] && [ "$DO_BUILD" -eq 0 ] && [ "$DO_RESTART" -eq 0 ]; then
	echo "Deployment completed successfully."
	exit 0
fi

echo "Running remote deployment steps..."
ssh "${SSH_OPTIONS[@]}" "$SERVER" <<EOF
set -euo pipefail

if [ ! -d "$BENCH_DIR" ]; then
	echo "Bench directory not found: $BENCH_DIR" >&2
	exit 1
fi

cd "$BENCH_DIR"
if [ "$DO_INSTALL" -eq 1 ] || [ "$DO_BUILD" -eq 1 ]; then
 	if [ ! -d "$REMOTE_APP_DIR" ]; then
 		echo "Remote app directory not found: $REMOTE_APP_DIR" >&2
 		exit 1
 	fi
fi

if [ "$DO_INSTALL" -eq 1 ]; then
	"$BENCH_DIR/env/bin/pip" install -e "apps/$APP_NAME"

touch sites/apps.txt
tmp_apps="\$(mktemp)"
while IFS= read -r app_line || [ -n "\$app_line" ]; do
	if [ "\$app_line" != "$APP_NAME" ] && [[ "\$app_line" == *"$APP_NAME" ]]; then
		prefix="\${app_line%$APP_NAME}"
		if [ -n "\$prefix" ] && [ -d "apps/\$prefix" ]; then
			printf '%s\n' "\$prefix"
			printf '%s\n' "$APP_NAME"
			continue
		fi
	fi

	printf '%s\n' "\$app_line"
done < sites/apps.txt > "\$tmp_apps"
mv "\$tmp_apps" sites/apps.txt

if ! grep -Fxq "$APP_NAME" sites/apps.txt; then
	printf '%s\n' "$APP_NAME" >> sites/apps.txt
fi

if [ "$SKIP_INSTALL_APP" -eq 0 ] && ! bench --site "$SITE" list-apps | awk '{print \$1}' | grep -Fxq "$APP_NAME"; then
	if [ "$REQUIRE_NODE_ON_INSTALL" -eq 1 ]; then
		if [ -s "\$HOME/.nvm/nvm.sh" ]; then
			. "\$HOME/.nvm/nvm.sh"
		fi

		if [ -d "\$HOME/.local/bin" ]; then
			export PATH="\$HOME/.local/bin:\$PATH"
		fi

		if ! command -v node >/dev/null 2>&1; then
			echo "Node.js is required for first-time $APP_NAME installation." >&2
			echo "Make node available to non-interactive SSH, then rerun this script." >&2
			exit 1
		fi
	fi

	bench --site "$SITE" install-app "$APP_NAME"
fi
fi

if [ "$DO_MIGRATE" -eq 1 ]; then
	bench --site "$SITE" migrate
else
	echo "Skipping migrate."
fi

if [ "$DO_BUILD" -eq 1 ]; then
	bench build --app "$APP_NAME"
else
	echo "Skipping build."
fi

if [ "$DO_RESTART" -eq 1 ]; then
	bench restart
else
	echo "Skipping restart."
fi
EOF

echo "Deployment completed successfully."
