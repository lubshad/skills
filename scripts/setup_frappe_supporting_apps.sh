#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BENCH="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOST="" USER_NAME=frappe PORT=22 KEY="" BENCH=/home/frappe/frappe-bench SITE=""
EXECUTE=0 BUILD=1
KINDS=() SOURCES=() BRANCHES=()
# The same filters protect staging uploads and existing server-only files.
EXCLUDES=(.git .github .env '.env.*' '*.pem' '*.key' '*.p12' '*.pfx'
  '*service-account*.json' '*firebase-adminsdk*.json' personal sshmain.sh
  __pycache__ '*.pyc' .ruff_cache .pytest_cache .mypy_cache .venv venv env
  node_modules '*.egg-info' dist build .DS_Store)

usage() {
  cat <<'EOF'
Usage: setup_frappe_supporting_apps.sh --host HOST [apps] [options]

Run locally after server setup. Dry-run by default (no SSH connection).
  --app NAME           Sync local <bench>/apps/NAME; repeatable
  --git-app HTTPS_URL  Add with bench get-app, or update a public Git app; repeatable
  --branch BRANCH      Required immediately after each --git-app URL
  --host HOST          Required SSH host (not necessarily the site hostname)
  --execute            Apply changes; otherwise print the plan
  --site SITE          Also install apps on this site and migrate it
  --ssh-user USER      Default: frappe (must own the Bench)
  --ssh-port PORT      Default: 22
  --ssh-key PATH       Default: <local-bench>/personal if present, else SSH defaults
  --bench-dir PATH     Default: /home/frappe/frappe-bench
  --build              Build assets for all Bench apps (default)
  --skip-build         Explicitly skip the asset build before restarting
  -h, --help           Show help

Examples:
  setup_frappe_supporting_apps.sh --host ssh.sync-app.in --app flutter_utils --app agora_integration
  setup_frappe_supporting_apps.sh --host SERVER --git-app https://github.com/frappe/erpnext.git --branch version-16

Apps are processed in the supplied order. Put dependencies first.
Git repository basenames must match their Python app names (e.g. erpnext).
Existing Git apps require the same origin/branch and a clean, fast-forwardable
checkout. Local sync refuses to overwrite a Git-managed app. Public Git access
is non-interactive. No sudo, GitHub credentials, forced resets, or site creation.
New Git apps use bench get-app --skip-assets, which installs the Python package
and registers the app. Existing Git updates refresh the Python package. Git code
is first cloned into staging for preflight checks. All Bench app assets are built
by default before restarting. Use --skip-build only when a build is not needed.

Execute takes source backups under <bench>/.supporting-app-backups and, when
--site is supplied, a Bench site backup before modifying live app source.
Backups are retained. There is no automatic rollback of database migrations.
Bench-only updates still affect every site using these apps; schema updates need
migration of each affected site. Coordinate with CI deployments: this script's
lock serializes only other runs of this script. Local uncommitted code is synced.
Rsync removes obsolete non-excluded files inside selected local app directories.
Credentials under other filenames must be removed from source before syncing.
EOF
}
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
value() { [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail "Missing value for $1"; }
while (($#)); do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --execute) EXECUTE=1; shift ;;
    --build) BUILD=1; shift ;;
    --skip-build) BUILD=0; shift ;;
    --app|--git-app)
      value "$@"
      KINDS+=("$1"); SOURCES+=("$2"); BRANCHES+=(""); shift 2 ;;
    --branch)
      value "$@"; i=$((${#KINDS[@]} - 1))
      [[ $i -ge 0 && ${KINDS[$i]} == --git-app && -z ${BRANCHES[$i]} ]] || fail '--branch must follow a --git-app'
      BRANCHES[$i]="$2"; shift 2 ;;
    --host|--ssh-user|--ssh-port|--ssh-key|--bench-dir|--site)
      value "$@"
      case "$1" in
        --host) HOST="$2" ;; --ssh-user) USER_NAME="$2" ;; --ssh-port) PORT="$2" ;;
        --ssh-key) KEY="$2" ;; --bench-dir) BENCH="$2" ;; --site) SITE="$2" ;;
      esac
      shift 2 ;;
    *) fail "Unknown option: $1" ;;
  esac
done
[[ $HOST =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || fail '--host must be a hostname or IPv4 address'
[[ $USER_NAME =~ ^[a-z_][a-z0-9_-]*$ ]] || fail 'Invalid SSH user'
[[ $PORT =~ ^[0-9]{1,5}$ ]] && ((10#$PORT > 0 && 10#$PORT <= 65535)) || fail 'Invalid SSH port'
[[ $BENCH =~ ^/[a-zA-Z0-9_./-]+$ && $BENCH != / && $BENCH != *'/../'* && $BENCH != */.. ]] || fail 'Invalid absolute Bench path'
BENCH=${BENCH%/}
[[ -z $SITE || $SITE =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || fail 'Invalid site name'
((${#KINDS[@]})) || fail 'Supply at least one --app or --git-app'
[[ -n $KEY || ! -f $LOCAL_BENCH/personal ]] || KEY="$LOCAL_BENCH/personal"
[[ -z $KEY || -f $KEY ]] || fail "SSH key not found: $KEY"
NAMES=()
for i in "${!KINDS[@]}"; do
  source=${SOURCES[$i]}
  if [[ ${KINDS[$i]} == --app ]]; then
    name=$source
  else
    [[ $source =~ ^https://[a-zA-Z0-9.-]+/[a-zA-Z0-9_./-]+$ && $source != *'/../'* ]] || fail 'Public Git apps require an HTTPS URL without credentials or query parameters'
    name=${source##*/}; name=${name%.git}
    [[ -n ${BRANCHES[$i]} ]] || fail "--branch is required for $source"
    git check-ref-format --branch "${BRANCHES[$i]}" >/dev/null 2>&1 || fail 'Invalid Git branch'
  fi
  [[ $name =~ ^[a-z][a-z0-9_]*$ && $name != frappe ]] || fail "Invalid supporting app name: $name"
  for previous in "${NAMES[@]}"; do [[ $previous != "$name" ]] || fail "Duplicate app: $name"; done
  NAMES+=("$name")
  if [[ ${KINDS[$i]} == --app ]]; then
    [[ -f $LOCAL_BENCH/apps/$name/pyproject.toml && -f $LOCAL_BENCH/apps/$name/$name/hooks.py && ! -L $LOCAL_BENCH/apps/$name ]] || fail "Not a local packaged Frappe app: $name"
  fi
done

printf 'Target: %s@%s:%s, Bench: %s\n' "$USER_NAME" "$HOST" "$PORT" "$BENCH"
for i in "${!NAMES[@]}"; do
  printf '  %s: %s -> apps/%s' "${KINDS[$i]#--}" "${SOURCES[$i]}" "${NAMES[$i]}"
  [[ -z ${BRANCHES[$i]} ]] || printf ' (branch %s)' "${BRANCHES[$i]}"
  printf '\n'
done
printf 'Back up source; install Python packages; register Bench apps; restart services.\n'
[[ -z $SITE ]] || printf 'Back up site %s; install missing apps; migrate site.\n' "$SITE"
if ((BUILD)); then
  printf 'Build assets for all Bench apps.\n'
else
  printf 'Skip asset build (explicit opt-out).\n'
fi
if ((EXECUTE == 0)); then
  printf 'Dry-run only. No server connection or changes. Add --execute to apply.\n'
  exit 0
fi
for cmd in ssh rsync; do command -v "$cmd" >/dev/null || fail "Missing command: $cmd"; done
SSH=(ssh -p "$PORT" -o BatchMode=yes -o StrictHostKeyChecking=yes)
[[ -z $KEY ]] || SSH+=(-i "$KEY")
TARGET="$USER_NAME@$HOST"
remote() {
  local command arg
  command='bash -s --'
  for arg in "$@"; do printf -v arg '%q' "$arg"; command+=" $arg"; done
  "${SSH[@]}" "$TARGET" "$command"
}

# Staging is unique to this invocation; a failed run retains it for inspection.
STAGE=$(remote "$BENCH" <<'REMOTE'
set -euo pipefail
cd "$1"
[[ -d apps && -f sites/apps.txt && -x env/bin/python ]] || { echo 'Invalid remote Bench' >&2; exit 1; }
[[ $(stat -c %u .) == "$(id -u)" ]] || { echo 'SSH user must own the Bench' >&2; exit 1; }
umask 077
mkdir -p .supporting-app-staging
mktemp -d "$PWD/.supporting-app-staging/run.XXXXXXXX"
REMOTE
)
[[ $STAGE == "$BENCH"/.supporting-app-staging/run.* && $STAGE != *$'\n'* ]] || fail 'Unexpected remote staging path'
trap 'printf "Sync failed. Inspect retained staging: %s\n" "$STAGE" >&2' ERR
printf -v RSYNC_SSH '%q ' "${SSH[@]}"
FILTERS=()
for pattern in "${EXCLUDES[@]}"; do FILTERS+=(--exclude="$pattern"); done
for i in "${!NAMES[@]}"; do
  [[ ${KINDS[$i]} == --app ]] || continue
  rsync -rltz --safe-links --chmod=Du=rwx,Dgo=rx,Fu=rwX,Fgo=rX --protect-args \
    "${FILTERS[@]}" -e "$RSYNC_SSH" \
    "$LOCAL_BENCH/apps/${NAMES[$i]}/" "$TARGET:$STAGE/${NAMES[$i]}/"
done

apply_remote() {
  set -Eeuo pipefail
  umask 077
  export PATH="$HOME/.local/bin:$PATH" GIT_TERMINAL_PROMPT=0 PYTHONDONTWRITEBYTECODE=1
  cd "$BENCH"
  exec 9>.supporting-app-sync.lock
  flock -n 9 || { echo 'Another supporting-app sync is running' >&2; exit 1; }
  trap 'echo "Failed during: $STEP. Backups/staging retained; no automatic rollback." >&2' ERR
  STEP=preflight
  for cmd in git rsync flock tar bench; do command -v "$cmd" >/dev/null; done
  [[ -z $SITE || ( -d sites/$SITE && ! -L sites/$SITE && -f sites/$SITE/site_config.json ) ]]
  # Load Node for install hooks and optional asset builds, if configured.
  if [[ -s $HOME/.nvm/nvm.sh ]]; then
    set +u
    source "$HOME/.nvm/nvm.sh"
    set -u
  fi
  for i in "${!NAMES[@]}"; do
    name=${NAMES[$i]}; dest="apps/$name"
    [[ ! -L $dest && ( ! -e $dest || -d $dest ) ]]
    if [[ ${KINDS[$i]} == --git-app ]]; then
      branch=${BRANCHES[$i]}; url=${SOURCES[$i]}
      git clone --single-branch --branch "$branch" -- "$url" "$STAGE/$name"
      if [[ -d $dest ]]; then
        [[ -d $dest/.git && ! -L $dest/.git ]]
        [[ $(git -C "$dest" config --get remote.origin.url) == "$url" ]]
        [[ $(git -C "$dest" branch --show-current) == "$branch" ]]
        [[ -z $(git -C "$dest" status --porcelain --untracked-files=all) ]]
        git -C "$dest" fetch --no-tags origin "refs/heads/$branch"
        [[ $(git -C "$dest" rev-parse FETCH_HEAD) == "$(git -C "$STAGE/$name" rev-parse HEAD)" ]]
        git -C "$dest" merge-base --is-ancestor HEAD FETCH_HEAD
      fi
    else
      [[ ! -e $dest/.git ]] || { echo "Refusing local sync over Git checkout: $name" >&2; exit 1; }
    fi
    [[ -f $STAGE/$name/pyproject.toml && -f $STAGE/$name/$name/hooks.py ]]
  done
  # Inspect literal required_apps without importing app code. Require dependencies
  # before consumers, or already registered (and installed for site operations).
  env/bin/python - "$STAGE" "$SITE" "${NAMES[@]}" <<'PY'
import ast
import json
import pathlib
import subprocess
import sys
stage, site, *names = sys.argv[1:]
available = set(pathlib.Path('sites/apps.txt').read_text().split()) - set(names)
installed = set()
if site:
    installed = set(json.loads(subprocess.check_output(
        ['bench', '--site', site, 'list-apps', '--format', 'json'], text=True))[site])
for name in names:
    tree = ast.parse((pathlib.Path(stage) / name / name / 'hooks.py').read_text())
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'required_apps' for t in node.targets):
            dependencies = ast.literal_eval(node.value)
            if not isinstance(dependencies, (list, tuple)) or not all(isinstance(d, str) for d in dependencies):
                raise SystemExit(f'Unsupported required_apps in {name}')
            for dependency in dependencies:
                if dependency not in available or (site and dependency not in installed):
                    raise SystemExit(f'{name} requires {dependency}; supply it first, or install it beforehand')
    available.add(name)
    installed.add(name)
PY
  STEP=backup
  backup="$BENCH/.supporting-app-backups/${STAGE##*/}"
  mkdir -p "$backup"
  cp -p sites/apps.txt "$backup/apps.txt"
  for name in "${NAMES[@]}"; do
    if [[ -d apps/$name ]]; then tar -czf "$backup/$name.tar.gz" -C apps "$name"; fi
  done
  [[ -z $SITE ]] || bench --site "$SITE" backup --with-files
  printf 'Source backups: %s\n' "$backup"
  filters=()
  for pattern in "${EXCLUDES[@]}"; do filters+=(--exclude="$pattern"); done
  # Finish each app's package setup before fetching its dependent apps with Bench.
  for i in "${!NAMES[@]}"; do
    name=${NAMES[$i]}
    STEP="source-sync:$name"
    if [[ ${KINDS[$i]} == --git-app ]]; then
      if [[ -d apps/$name ]]; then
        git -C "apps/$name" merge --ff-only "$(git -C "$STAGE/$name" rev-parse HEAD)"
      else
        STEP="bench-get-app:$name"
        bench get-app --branch "${BRANCHES[$i]}" --skip-assets "${SOURCES[$i]}"
        # Do not silently deploy a branch that moved after dependency preflight.
        [[ $(git -C "apps/$name" rev-parse HEAD) == "$(git -C "$STAGE/$name" rev-parse HEAD)" ]]
        # Bench already installed the package and registered it in apps.txt.
        continue
      fi
    else
      mkdir -p "apps/$name"
      rsync -rlt --delete --safe-links --chmod=Du=rwx,Dgo=rx,Fu=rwX,Fgo=rX "${filters[@]}" "$STAGE/$name/" "apps/$name/"
    fi
    STEP="package-install:$name"
    env/bin/python -m pip install -e "apps/$name"
    STEP="bench-registration:$name"
    env/bin/python - "$name" <<'PY'
import os
import pathlib
import sys
path = pathlib.Path('sites/apps.txt')
apps = list(dict.fromkeys(path.read_text().split() + sys.argv[1:]))
temp = path.with_name('apps.txt.supporting-app-sync')
with temp.open('x') as stream:
    os.chmod(temp, path.stat().st_mode & 0o777)
    stream.write('\n'.join(apps) + '\n')
os.replace(temp, path)
PY
  done
  if [[ -n $SITE ]]; then
    STEP=site-install
    for name in "${NAMES[@]}"; do
      installed=$(env/bin/python - "$SITE" "$name" <<'PY'
import json
import subprocess
import sys
apps = json.loads(subprocess.check_output(
    ['bench', '--site', sys.argv[1], 'list-apps', '--format', 'json'], text=True))
print('yes' if sys.argv[2] in apps[sys.argv[1]] else 'no')
PY
      )
      if [[ $installed == no ]]; then
        bench --site "$SITE" install-app "$name"
      fi
    done
    STEP=migration
    bench --site "$SITE" migrate
  fi
  if ((BUILD)); then
    STEP=asset-build
    bench build
  fi
  STEP=public-asset-permissions
  # Only public assets are group-readable. Parent paths need traversal, not reads.
  # Provisioning adds the nginx user to the Bench owner's group.
  env/bin/python - <<'PY'
import os
from pathlib import Path
import stat

root = Path.cwd()
gid = root.stat().st_gid
def grant(path, bits):
    if path.is_symlink():
        raise RuntimeError(f'Refusing symlink permission change: {path}')
    current = path.stat()
    if current.st_gid != gid:
        raise RuntimeError(f'Unexpected group on public asset path: {path}')
    path.chmod(stat.S_IMODE(current.st_mode) | bits)

for app in (root / 'sites/apps.txt').read_text().split():
    if not app.isidentifier():
        raise RuntimeError('Invalid registered app name')
    public = root / 'apps' / app / app / 'public'
    if not public.is_dir():
        continue
    for parent in [root.parent, root, root / 'apps', public.parent.parent, public.parent]:
        grant(parent, stat.S_IXGRP)
    grant(public, stat.S_IRGRP | stat.S_IXGRP)
    for directory, dirs, files in os.walk(public, followlinks=False):
        for name in dirs:
            path = Path(directory) / name
            if not path.is_symlink():
                grant(path, stat.S_IRGRP | stat.S_IXGRP)
        for name in files:
            path = Path(directory) / name
            if not path.is_symlink() and path.is_file():
                grant(path, stat.S_IRGRP)
    print(f'Public asset group access verified: {app}')
PY
  STEP=restart
  bench restart
  STEP=verification
  env/bin/python - "${NAMES[@]}" <<'PY'
import importlib
import sys
for name in sys.argv[1:]:
    importlib.import_module(name)
    print(f'Import verified: {name}')
PY
  [[ -z $SITE ]] || bench --site "$SITE" list-apps
  STEP=complete
  printf 'Sync completed. No public HTTP health check was performed.\n'
}
{
  declare -p BENCH SITE BUILD STAGE KINDS SOURCES BRANCHES NAMES EXCLUDES
  declare -f apply_remote
  printf 'apply_remote\n'
} | remote
trap - ERR
printf 'Remote staging retained: %s\n' "$STAGE"
