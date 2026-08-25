#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SSH_KEY="$SCRIPT_DIR/../../personal"

EXECUTE=0
SSH_USER="root"
SSH_HOST=""
SSH_PORT="22"
SSH_KEY="$DEFAULT_SSH_KEY"
BENCH_USER="frappe"
BENCH_DIR="/home/frappe/frappe-bench"
FRAPPE_VERSION="16"
FRAPPE_BRANCH=""
DEFAULT_APP_BRANCH="version-16"
PYTHON_VERSION="3.14"
NODE_VERSION="24"
SWAP_FILE="/swapfile"
SWAP_SIZE_GB="4"
SITE_NAME=""
ADMIN_PASSWORD=""
MARIADB_ROOT_PASSWORD=""
INSTALL_PRODUCTION=1
ENABLE_SCHEDULER=1
SETUP_SWAP=1
CONFIGURE_MARIADB=1
SETUP_SSL=0
SSL_EMAIL=""
APPS=()
APP_BRANCHES=()
INSTALL_APPS=()
APT_PACKAGES="build-essential certbot curl git cron libfontconfig libffi-dev libjpeg-dev liblcms2-dev libldap2-dev libmariadb-dev libpq-dev libsasl2-dev libssl-dev mariadb-client mariadb-server nginx pkg-config redis-server sudo supervisor tzdata util-linux xvfb zlib1g-dev python3-certbot-nginx"

usage() {
  cat <<'USAGE'
Usage:
  setup_frappe_server.sh --site SITE --admin-password PASS --mariadb-root-password PASS [options]

Run this script from your local machine. It SSHes into the remote server, creates the
remote frappe Linux user if needed, and performs a full Frappe Bench setup there.
The remote server must run Ubuntu or Debian.

Defaults to dry-run. Add --execute to run remote commands.

Required:
  --site SITE                       Frappe site name, e.g. example.com
  --admin-password PASS             Frappe Administrator password for new site
  --mariadb-root-password PASS      MariaDB root password used by bench new-site
  --ssl-email EMAIL                 Let's Encrypt registration email

Options:
  --execute                         Run commands instead of printing them
  --host HOST                       Remote server host/IP (default: --site value)
  --ssh-user USER                   Remote SSH login user (default: root)
  --ssh-key PATH                    SSH private key path (default: <bench>/personal)
  --ssh-port PORT                   SSH port (default: 22)
  --bench-user USER                 Remote Linux user that owns the bench (default: frappe)
  --bench-dir PATH                  Remote bench path (default: /home/frappe/frappe-bench)
  --frappe-version VERSION          Frappe major version or develop (default: 16)
  --frappe-branch BRANCH            Custom Frappe branch for bench init (overrides --frappe-version)
  --python-version VERSION          uv-managed Python version (default: 3.14)
  --node-version VERSION            nvm-managed Node version (default: 24)
  --swap-file PATH                  Remote swap file path (default: /swapfile)
  --swap-size-gb SIZE               Remote swap size in GB (default: 4)
  --skip-swap                       Skip remote swap file setup
  --skip-mariadb-config             Skip MariaDB service/root-password setup
  --app REPO                        bench get-app repository; repeatable (default branch: version-16)
  --app-branch BRANCH               Override branch for the immediately preceding --app
  --install-app APP                 App name to install on site; repeatable
  --skip-production                 Skip Bench production setup
  --skip-scheduler                  Skip bench enable-scheduler
  -h, --help                        Show this help

Examples:
  setup_frappe_server.sh --site example.com --frappe-version 16 --ssl-email admin@example.com --admin-password x --mariadb-root-password y
  setup_frappe_server.sh --execute --host 203.0.113.10 --site example.com --admin-password x --mariadb-root-password y --app https://github.com/frappe/erpnext --app-branch version-16 --install-app erpnext
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
  printf '%s@%s' "$SSH_USER" "$SSH_HOST"
}

ssh_args() {
  local args=(-p "$SSH_PORT")
  if [[ -n "$SSH_KEY" ]]; then
    args+=(-i "$SSH_KEY")
  fi
  printf '%q ' "${args[@]}"
}

remote_shell() {
  local command="$1"
  local strict_command="set -euo pipefail; $command"
  local target
  target="$(ssh_target)"

  if [[ "$EXECUTE" -eq 1 ]]; then
    printf '+ ssh %s%s %q\n' "$(ssh_args)" "$target" "bash -lc $(quote "$strict_command")"
    local args=(-p "$SSH_PORT")
    if [[ -n "$SSH_KEY" ]]; then
      args+=(-i "$SSH_KEY")
    fi
    ssh "${args[@]}" "$target" "bash -lc $(quote "$strict_command")"
  else
    printf '[dry-run] ssh %s%s %q\n' "$(ssh_args)" "$target" "bash -lc $(quote "$strict_command")"
  fi
}

remote_privileged() {
  local command="$1"
  local strict_command="set -euo pipefail; $command"
  remote_shell "if [ \"\$(id -u)\" -eq 0 ]; then bash -lc $(quote "$strict_command"); else sudo bash -lc $(quote "$strict_command"); fi"
}

remote_as_bench_user() {
  local command="$1"
  local bench_home
  bench_home="/home/$BENCH_USER"
  local remote_command
  remote_command="set -euo pipefail; cd $bench_home && $command"
  local args=(-p "$SSH_PORT")
  if [[ -n "$SSH_KEY" ]]; then
    args+=(-i "$SSH_KEY")
  fi
  if [[ "$EXECUTE" -eq 1 ]]; then
    ssh "${args[@]}" "${BENCH_USER}@${SSH_HOST}" "bash -lc $(quote "$remote_command")"
  else
    printf '[dry-run] ssh %s%s %q\n' "$(ssh_args)" "${BENCH_USER}@${SSH_HOST}" "bash -lc $(quote "$remote_command")"
  fi
}

remote_as_bench_user_privileged() {
  local command="$1"
  local strict_command="set -euo pipefail; $command"
  remote_as_bench_user "sudo bash -lc $(quote "$strict_command")"
}

apt_install_command() {
  local missing_check=""
  local package

  for package in $APT_PACKAGES; do
    missing_check="${missing_check} dpkg -s $(quote "$package") >/dev/null 2>&1 || missing=\"\$missing $(quote "$package")\";"
  done

  cat <<EOF
missing="";
${missing_check}
if [ -n "\$missing" ]; then
  apt-get update;
  DEBIAN_FRONTEND=noninteractive apt-get install -y \$missing;
else
  printf 'APT dependencies already installed.\n';
fi
EOF
}

python_dev_install_command() {
  local package="python${PYTHON_VERSION}-dev"

  cat <<EOF
if dpkg -s $(quote "$package") >/dev/null 2>&1; then
  printf '%s already installed.\n' $(quote "$package");
else
  candidate="\$(apt-cache policy $(quote "$package") | awk '/Candidate:/ {print \$2}')";
  if [ -n "\$candidate" ] && [ "\$candidate" != "(none)" ]; then
    apt-get update;
    DEBIAN_FRONTEND=noninteractive apt-get install -y $(quote "$package");
  else
    printf '%s is unavailable from APT; using uv-managed Python instead.\n' $(quote "$package");
  fi
fi
EOF
}

wkhtmltopdf_install_command() {
  cat <<'EOF'
if command -v wkhtmltopdf >/dev/null 2>&1; then
  printf 'wkhtmltopdf already installed.\n'
else
  candidate="$(apt-cache policy wkhtmltopdf | awk '/Candidate:/ {print $2}')"
  if [ -n "$candidate" ] && [ "$candidate" != "(none)" ]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y wkhtmltopdf
  else
    printf 'wkhtmltopdf is unavailable from the configured APT repositories; continuing without PDF generation support.\n' >&2
  fi
fi
EOF
}

os_preflight_command() {
  cat <<'EOF'
if ! command -v apt-get >/dev/null 2>&1; then
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    printf 'Unsupported server OS: %s. This setup script requires Ubuntu or Debian.\n' "${PRETTY_NAME:-unknown}" >&2
  else
    printf 'Unsupported server OS: apt-get is required by this setup script.\n' >&2
  fi
  exit 1
fi

if [ -r /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian) ;;
    *)
      printf 'Unsupported server OS: %s. This setup script requires Ubuntu or Debian.\n' "${PRETTY_NAME:-unknown}" >&2
      exit 1
      ;;
  esac
fi
EOF
}

bench_user_env() {
  printf 'export PATH="$HOME/.local/bin:$PATH"; NVM_DIR=""; for _d in "$HOME/.nvm" "$HOME/.config/nvm"; do if [ -s "$_d/nvm.sh" ]; then NVM_DIR="$_d"; break; fi; done; if [ -z "$NVM_DIR" ]; then echo "nvm is not installed" >&2; exit 1; fi; export NVM_DIR; . "$NVM_DIR/nvm.sh"; %s' "$1"
}

ssl_setup_command() {
  local email_quoted site_quoted bench_dir_quoted
  email_quoted="$(quote "$SSL_EMAIL")"
  site_quoted="$(quote "$SITE_NAME")"
  bench_dir_quoted="$(quote "$BENCH_DIR")"
  cat <<EOF
cd ${bench_dir_quoted};

bench config dns_multitenant on;

printf 'email = %s\nagree-tos = true\nnon-interactive = true\n' ${email_quoted} | sudo tee /etc/letsencrypt/cli.ini >/dev/null;

if [ -f /etc/letsencrypt/live/${site_quoted}/fullchain.pem ] && [ -f /etc/letsencrypt/live/${site_quoted}/privkey.pem ] && grep -Fq /etc/letsencrypt/live/${site_quoted}/fullchain.pem config/nginx.conf; then
  printf "Let's Encrypt SSL is already configured for %s.\n" ${site_quoted};
else
  printf 'y\ny\n' | sudo bench setup lets-encrypt ${site_quoted};
  printf "Let's Encrypt SSL configured for %s via bench.\n" ${site_quoted};
fi
EOF
}

supervisor_reload_command() {
  cat <<EOF
if [ -f $(quote "$BENCH_DIR/config/supervisor.conf") ]; then
  ln -sfn $(quote "$BENCH_DIR/config/supervisor.conf") /etc/supervisor/conf.d/$(quote "$(basename "$BENCH_DIR")").conf;
  systemctl is-enabled --quiet supervisor || systemctl enable supervisor;
  systemctl is-active --quiet supervisor || systemctl start supervisor;
  supervisorctl reread;
  supervisorctl update;
  not_running="\$(supervisorctl status | awk '/redis/ && \$2 != "RUNNING" {print \$1}')";
  if [ -n "\$not_running" ]; then
    supervisorctl start \$not_running;
  else
    printf 'Bench redis supervisor services already running.\n';
  fi;
  supervisorctl status;
else
  printf 'Bench supervisor config missing; skipping supervisor reload.\n';
fi
EOF
}

nginx_reload_command() {
  cat <<EOF
if [ -f $(quote "$BENCH_DIR/config/nginx.conf") ]; then
  if command -v nginx >/dev/null 2>&1; then
    systemctl is-enabled --quiet nginx || systemctl enable nginx;
    systemctl is-active --quiet nginx || systemctl start nginx;
    nginx_error="\$(nginx -t 2>&1 || true)";
    if [[ "\$nginx_error" == *'unknown log format "main"'* ]]; then
      cat > /etc/nginx/conf.d/00-frappe-log-format.conf <<'NGINX_LOG_FORMAT'
log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" \$status \$body_bytes_sent';
NGINX_LOG_FORMAT
    fi;
    nginx -t && systemctl reload nginx;
  else
    printf 'nginx not available; skipping nginx reload.\n';
  fi;
else
  printf 'Bench nginx config missing; skipping nginx reload.\n';
fi
EOF
}

migrate_command() {
  cat <<EOF
cd $(quote "$BENCH_DIR");
if command -v supervisorctl >/dev/null 2>&1 && sudo supervisorctl status 2>/dev/null | awk '/redis_cache|redis-cache/ && \$2 == "RUNNING" {found=1} END {exit found ? 0 : 1}'; then
  bench --site $(quote "$SITE_NAME") migrate;
else
  printf 'Skipping bench migrate because redis_cache is not running. Production setup/reload must complete first.\n' >&2;
  exit 1;
fi
EOF
}

production_health_check_command() {
  cat <<EOF
set -e;
systemctl is-active --quiet supervisor;
systemctl is-active --quiet nginx;
supervisorctl status | awk '/node-socketio/ && \$2 == "RUNNING" {found=1} END {exit found ? 0 : 1}';
if command -v ss >/dev/null 2>&1; then ss -lnt | awk '\$4 ~ /:9000\$/ {found=1} END {exit found ? 0 : 1}'; fi;
if command -v curl >/dev/null 2>&1; then
  curl -fsS -H $(quote "Host: $SITE_NAME") http://127.0.0.1/ >/dev/null;
  curl -fsS -H $(quote "Host: $SITE_NAME") 'http://127.0.0.1/socket.io/?EIO=4&transport=polling' >/dev/null;
fi;
printf 'Production services, Socket.IO, and %s are healthy through nginx.\n' $(quote "$SITE_NAME")
EOF
}

copy_authorized_keys_command() {
  cat <<EOF
source_keys="\$HOME/.ssh/authorized_keys";
if [ ! -s "\$source_keys" ] && [ -s /root/.ssh/authorized_keys ]; then
  source_keys="/root/.ssh/authorized_keys";
fi;
if [ -s "\$source_keys" ]; then
  target_home="\$(getent passwd $(quote "$BENCH_USER") | cut -d: -f6)";
  if [ -z "\$target_home" ]; then
    target_home=$(quote "/home/$BENCH_USER");
  fi;
  install -d -m 700 -o $(quote "$BENCH_USER") -g $(quote "$BENCH_USER") "\$target_home/.ssh";
  if [ ! -f "\$target_home/.ssh/authorized_keys" ] || ! cmp -s "\$source_keys" "\$target_home/.ssh/authorized_keys"; then
    install -m 600 -o $(quote "$BENCH_USER") -g $(quote "$BENCH_USER") "\$source_keys" "\$target_home/.ssh/authorized_keys";
    printf 'Copied authorized_keys to %s.\n' $(quote "$BENCH_USER");
  else
    printf 'authorized_keys already configured for %s.\n' $(quote "$BENCH_USER");
  fi;
else
  printf 'No authorized_keys found for SSH login user or root; skipping %s SSH key setup.\n' $(quote "$BENCH_USER");
fi
EOF
}

swap_setup_command() {
  local swap_size_mb=$((SWAP_SIZE_GB * 1024))
  local swap_file_quoted
  swap_file_quoted="$(quote "$SWAP_FILE")"

  cat <<EOF
if swapon --show=NAME --noheadings | grep -Fxq ${swap_file_quoted}; then
  printf 'Swap already active at %s\n' ${swap_file_quoted};
else
  if [ ! -f ${swap_file_quoted} ]; then
    fallocate -l ${SWAP_SIZE_GB}G ${swap_file_quoted} || dd if=/dev/zero of=${swap_file_quoted} bs=1M count=${swap_size_mb} status=progress;
    chmod 600 ${swap_file_quoted};
    mkswap ${swap_file_quoted};
  else
    chmod 600 ${swap_file_quoted};
  fi;
  swapon ${swap_file_quoted} || { mkswap ${swap_file_quoted}; swapon ${swap_file_quoted}; };
fi;
grep -Fq "${SWAP_FILE} none swap sw 0 0" /etc/fstab || printf '%s\n' "${SWAP_FILE} none swap sw 0 0" >> /etc/fstab
EOF
}

mariadb_setup_command() {
  local root_password_quoted
  local root_password_sql
  root_password_quoted="$(quote "$MARIADB_ROOT_PASSWORD")"
  root_password_sql="$(printf '%s' "$MARIADB_ROOT_PASSWORD" | sed "s/'/''/g")"

  cat <<EOF
systemctl is-enabled --quiet mariadb || systemctl enable mariadb;
systemctl is-active --quiet mariadb || systemctl start mariadb;
if mysql --protocol=TCP -h127.0.0.1 -uroot --password=${root_password_quoted} -e 'SELECT 1' >/dev/null 2>&1; then
  printf 'MariaDB root password already configured.\n';
elif mysql -uroot -e 'SELECT 1' >/dev/null 2>&1; then
  mysql -uroot <<SQL
DROP USER IF EXISTS 'root'@'localhost';
CREATE USER 'root'@'localhost' IDENTIFIED BY '${root_password_sql}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
SQL
else
  printf 'Unable to configure MariaDB root password. Check current MariaDB authentication manually.\n' >&2;
  exit 1;
fi
EOF
}

require_local_tools() {
  command -v ssh >/dev/null 2>&1 || fail "ssh is required on the local machine"
  if [[ -n "$SSH_KEY" && ! -f "$SSH_KEY" ]]; then
    fail "SSH key not found: $SSH_KEY"
  fi
}

require_values() {
  [[ -n "$SITE_NAME" ]] || fail "--site is required"
  SSH_HOST="${SSH_HOST:-$SITE_NAME}"
  [[ -n "$ADMIN_PASSWORD" ]] || fail "--admin-password is required"
  [[ -n "$MARIADB_ROOT_PASSWORD" ]] || fail "--mariadb-root-password is required"
  [[ -n "$SSL_EMAIL" ]] || fail "--ssl-email is required"
  [[ "$SWAP_SIZE_GB" =~ ^[1-9][0-9]*$ ]] || fail "--swap-size-gb must be a positive integer"
  [[ "$BENCH_DIR" == "/home/$BENCH_USER/"* || "$BENCH_DIR" == "/home/$BENCH_USER" ]] || {
    printf 'Warning: bench dir is outside /home/%s; verify ownership and service paths.\n' "$BENCH_USER" >&2
  }
}

resolve_frappe_branch() {
  if [[ -n "$FRAPPE_BRANCH" ]]; then
    return
  fi

  case "$FRAPPE_VERSION" in
    develop)
      FRAPPE_BRANCH="develop"
      ;;
    [1-9]|[1-9][0-9]*)
      FRAPPE_BRANCH="version-$FRAPPE_VERSION"
      ;;
    *)
      fail "--frappe-version must be a major version such as 16, or develop"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      EXECUTE=1
      shift
      ;;
    --host)
      SSH_HOST="${2:-}"
      shift 2
      ;;
    --ssh-user)
      SSH_USER="${2:-}"
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
    --site)
      SITE_NAME="${2:-}"
      shift 2
      ;;
    --admin-password)
      ADMIN_PASSWORD="${2:-}"
      shift 2
      ;;
    --mariadb-root-password)
      MARIADB_ROOT_PASSWORD="${2:-}"
      shift 2
      ;;
    --bench-user)
      BENCH_USER="${2:-}"
      shift 2
      ;;
    --bench-dir)
      BENCH_DIR="${2:-}"
      shift 2
      ;;
    --frappe-branch)
      FRAPPE_BRANCH="${2:-}"
      shift 2
      ;;
    --frappe-version)
      FRAPPE_VERSION="${2:-}"
      shift 2
      ;;
    --python-version)
      PYTHON_VERSION="${2:-}"
      shift 2
      ;;
    --node-version)
      NODE_VERSION="${2:-}"
      shift 2
      ;;
    --swap-file)
      SWAP_FILE="${2:-}"
      shift 2
      ;;
    --swap-size-gb)
      SWAP_SIZE_GB="${2:-}"
      shift 2
      ;;
    --skip-swap)
      SETUP_SWAP=0
      shift
      ;;
    --skip-mariadb-config)
      CONFIGURE_MARIADB=0
      shift
      ;;
    --app)
      APPS+=("${2:-}")
      APP_BRANCHES+=("$DEFAULT_APP_BRANCH")
      shift 2
      ;;
    --app-branch)
      [[ "${#APPS[@]}" -gt 0 ]] || fail "--app-branch must follow --app"
      APP_BRANCHES[$(( ${#APP_BRANCHES[@]} - 1 ))]="${2:-}"
      shift 2
      ;;
    --install-app)
      INSTALL_APPS+=("${2:-}")
      shift 2
      ;;
    --skip-production)
      INSTALL_PRODUCTION=0
      shift
      ;;
    --skip-scheduler)
      ENABLE_SCHEDULER=0
      shift
      ;;
    --ssl-email)
      SSL_EMAIL="${2:-}"
      SETUP_SSL=1
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

resolve_frappe_branch
require_values
require_local_tools

printf 'Using Frappe branch: %s\n' "$FRAPPE_BRANCH"

if [[ "$EXECUTE" -eq 0 ]]; then
  printf 'Dry-run mode. Re-run with --execute after reviewing remote SSH commands.\n'
fi

printf 'Phase 1/3: bootstrap Ubuntu services and the %s user.\n' "$BENCH_USER"
remote_privileged "$(os_preflight_command)"
remote_privileged "$(apt_install_command)"
remote_privileged "$(python_dev_install_command)"
remote_privileged "$(wkhtmltopdf_install_command)"

if [[ "$SETUP_SWAP" -eq 1 ]]; then
  remote_privileged "$(swap_setup_command)"
fi

if [[ "$CONFIGURE_MARIADB" -eq 1 ]]; then
  remote_privileged "$(mariadb_setup_command)"
fi

remote_privileged "if ! id $(quote "$BENCH_USER") >/dev/null 2>&1; then useradd --create-home --shell /bin/bash $(quote "$BENCH_USER"); fi"
remote_privileged "status=\$(passwd -S $(quote "$BENCH_USER") 2>/dev/null | awk '{print \$2}'); if [ \"\$status\" = L ]; then passwd -d $(quote "$BENCH_USER") >/dev/null; printf 'Unlocked %s for SSH public-key login.\\n' $(quote "$BENCH_USER"); else printf '%s account is not locked.\\n' $(quote "$BENCH_USER"); fi"
remote_privileged "if id -nG $(quote "$BENCH_USER") | tr ' ' '\n' | grep -Fxq sudo; then printf '%s is already in sudo group.\n' $(quote "$BENCH_USER"); else usermod -aG sudo $(quote "$BENCH_USER"); fi"
remote_privileged "if [ \"\$(cat /etc/sudoers.d/$(quote "$BENCH_USER") 2>/dev/null || true)\" != '$(quote "$BENCH_USER") ALL=(ALL) NOPASSWD:ALL' ]; then printf '%s\n' '$(quote "$BENCH_USER") ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$(quote "$BENCH_USER") && chmod 0440 /etc/sudoers.d/$(quote "$BENCH_USER"); else printf 'Sudoers entry already configured for %s.\n' $(quote "$BENCH_USER"); fi"
remote_privileged "$(copy_authorized_keys_command)"
remote_privileged "install -d -o $(quote "$BENCH_USER") -g $(quote "$BENCH_USER") $(quote "$(dirname "$BENCH_DIR")")"
remote_privileged "install -d -o $(quote "$BENCH_USER") -g $(quote "$BENCH_USER") $(quote "/home/$BENCH_USER/.config") $(quote "/home/$BENCH_USER/.cache") $(quote "/home/$BENCH_USER/.local") $(quote "/home/$BENCH_USER/.local/bin") $(quote "/home/$BENCH_USER/.local/share"); chown -R $(quote "$BENCH_USER"):$(quote "$BENCH_USER") $(quote "/home/$BENCH_USER/.config") $(quote "/home/$BENCH_USER/.cache") $(quote "/home/$BENCH_USER/.local")"

printf 'Phase 2/3: install and configure Frappe as %s.\n' "$BENCH_USER"
remote_as_bench_user 'for directory in "$HOME/.config" "$HOME/.cache" "$HOME/.local" "$HOME/.local/bin" "$HOME/.local/share"; do test -w "$directory"; done'
remote_as_bench_user "command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh"
remote_as_bench_user "test -s \"\$HOME/.nvm/nvm.sh\" || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
remote_as_bench_user "$(bench_user_env "uv python install $(quote "$PYTHON_VERSION") --default")"
remote_as_bench_user "$(bench_user_env "nvm version $(quote "$NODE_VERSION") >/dev/null 2>&1 || nvm install $(quote "$NODE_VERSION")")"
remote_as_bench_user "$(bench_user_env "command -v yarn >/dev/null 2>&1 || npm install -g yarn")"
remote_as_bench_user "$(bench_user_env 'node_bin="$(dirname "$(command -v node)")"; for executable in node npm npx yarn; do if [ -x "$node_bin/$executable" ]; then sudo ln -sfn "$node_bin/$executable" "/usr/local/bin/$executable"; fi; done; sudo test -x /usr/local/bin/node')"
remote_as_bench_user "$(bench_user_env "command -v bench >/dev/null 2>&1 || uv tool install frappe-bench")"
remote_as_bench_user "$(bench_user_env "command -v ansible-playbook >/dev/null 2>&1 || uv tool install ansible-core")"
remote_as_bench_user_privileged "if [ -x /home/$(quote "$BENCH_USER")/.local/bin/bench ]; then ln -sfn /home/$(quote "$BENCH_USER")/.local/bin/bench /usr/local/bin/bench; else printf 'Bench executable missing at /home/%s/.local/bin/bench.\\n' $(quote "$BENCH_USER") >&2; exit 1; fi; for executable in /home/$(quote "$BENCH_USER")/.local/bin/ansible*; do [ -x \"\$executable\" ] && ln -sfn \"\$executable\" \"/usr/local/bin/\$(basename \"\$executable\")\"; done"
remote_as_bench_user_privileged "for collection in community.general ansible.posix; do ansible-galaxy collection list \"\$collection\" | grep -Fq \"\$collection\" || ansible-galaxy collection install \"\$collection\" --collections-path /usr/share/ansible/collections; done"

remote_as_bench_user "$(bench_user_env "if [ ! -d $(quote "$BENCH_DIR") ]; then bench init --frappe-branch $(quote "$FRAPPE_BRANCH") --python $(quote "$PYTHON_VERSION") $(quote "$BENCH_DIR"); elif [ -d $(quote "$BENCH_DIR/apps/frappe") ] && [ -x $(quote "$BENCH_DIR/env/bin/python") ]; then if [ ! -f $(quote "$BENCH_DIR/sites/apps.txt") ] || ! $(quote "$BENCH_DIR/env/bin/python") -c 'import frappe' >/dev/null 2>&1; then printf 'Repairing the partial Frappe environment.\\n'; cd $(quote "$BENCH_DIR"); if [ ! -f sites/apps.txt ]; then printf 'frappe\\n' > sites/apps.txt; fi; uv pip install --quiet -e apps/frappe --python env/bin/python; else printf 'Bench directory exists: %s\\n' $(quote "$BENCH_DIR"); fi; else printf 'Partial bench directory at %s cannot be repaired automatically.\\n' $(quote "$BENCH_DIR") >&2; exit 1; fi")"
remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); if [ ! -d apps/frappe/node_modules ]; then bench setup requirements; fi; if [ ! -f sites/assets/assets.json ]; then bench build; fi")"

for app_index in "${!APPS[@]}"; do
  app="${APPS[$app_index]}"
  app_branch="${APP_BRANCHES[$app_index]}"
  app_name="$(basename "$app" .git)"
  if [[ -n "$app_branch" ]]; then
    remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); if [ -d apps/$(quote "$app_name") ]; then printf 'App %s already exists; skipping get-app.\\n' $(quote "$app_name"); else bench get-app --branch $(quote "$app_branch") $(quote "$app"); fi")"
  else
    remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); if [ -d apps/$(quote "$app_name") ]; then printf 'App %s already exists; skipping get-app.\\n' $(quote "$app_name"); else bench get-app $(quote "$app"); fi")"
  fi
done

remote_as_bench_user "if [ ! -d $(quote "$BENCH_DIR/sites/$SITE_NAME") ]; then $(bench_user_env "cd $(quote "$BENCH_DIR"); bench new-site $(quote "$SITE_NAME") --admin-password $(quote "$ADMIN_PASSWORD") --mariadb-root-password $(quote "$MARIADB_ROOT_PASSWORD")"); else printf 'Site directory exists: %s/sites/%s\n' $(quote "$BENCH_DIR") $(quote "$SITE_NAME"); fi"

if [[ "$INSTALL_PRODUCTION" -eq 1 ]]; then
  printf 'Phase 3/3: configure production services and start Bench services.\n'
  remote_as_bench_user_privileged "systemctl is-enabled --quiet nginx || systemctl enable nginx; systemctl is-active --quiet nginx || systemctl start nginx"
  remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); if [ -f config/supervisor.conf ] && [ -f config/nginx.conf ]; then printf 'Production config already exists; skipping bench setup production.\n'; else sudo /home/$(quote "$BENCH_USER")/.local/bin/bench setup production $(quote "$BENCH_USER") --yes; fi")"
  remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); printf 'y\\n' | bench setup supervisor; grep -Fq '[program:$(basename "$BENCH_DIR")-node-socketio]' config/supervisor.conf")"
  remote_as_bench_user_privileged "$(supervisor_reload_command)"
  remote_as_bench_user_privileged "$(nginx_reload_command)"
fi

for app_name in "${INSTALL_APPS[@]+"${INSTALL_APPS[@]}"}"; do
  remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); if bench --site $(quote "$SITE_NAME") list-apps | awk '{print \$1}' | grep -Fxq $(quote "$app_name"); then printf 'App %s already installed on site; skipping install-app.\\n' $(quote "$app_name"); else bench --site $(quote "$SITE_NAME") install-app $(quote "$app_name"); fi")"
done

remote_as_bench_user "$(bench_user_env "$(migrate_command)")"

if [[ "$ENABLE_SCHEDULER" -eq 1 ]]; then
  remote_as_bench_user "$(bench_user_env "cd $(quote "$BENCH_DIR"); if bench --site $(quote "$SITE_NAME") scheduler status 2>/dev/null | grep -qi 'enabled'; then printf 'Scheduler already enabled for %s.\\n' $(quote "$SITE_NAME"); else bench --site $(quote "$SITE_NAME") enable-scheduler; fi")"
fi

if [[ "$INSTALL_PRODUCTION" -eq 1 ]]; then
  remote_as_bench_user_privileged "$(production_health_check_command)"
fi

if [[ "$SETUP_SSL" -eq 1 ]]; then
  remote_as_bench_user "$(ssl_setup_command)"
fi

printf 'Remote Frappe server setup flow completed for %s on %s.\n' "$SITE_NAME" "$(ssh_target)"
