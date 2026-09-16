#!/usr/bin/env bash
set -euo pipefail

readonly OPENCODE_BIN="/home/lubshad/.opencode/bin/opencode"
readonly OPENCODE_USER="lubshad"
readonly OPENCODE_HOME="/home/lubshad"
readonly OPENCODE_PORT="4096"
readonly PUBLIC_URL="https://opencode.coreaxissolutions.in"
readonly SERVICE_FILE="/etc/systemd/system/opencode-web.service"
readonly ENV_FILE="/etc/opencode-web.env"

if [[ ! -t 0 ]]; then
  printf 'Run this installer from an interactive terminal.\n' >&2
  exit 1
fi

if [[ ! -x "$OPENCODE_BIN" ]]; then
  printf 'OpenCode was not found at %s.\n' "$OPENCODE_BIN" >&2
  exit 1
fi

printf 'This installer requires sudo to install and enable boot services.\n'
sudo -v

while true; do
  read -r -p 'Choose the OpenCode web username: ' opencode_username

  if [[ -z "$opencode_username" ]]; then
    printf 'The username cannot be empty.\n' >&2
  else
    break
  fi
done

while true; do
  read -r -s -p 'Choose the OpenCode web password: ' opencode_password
  printf '\n'
  read -r -s -p 'Confirm the OpenCode web password: ' opencode_password_confirm
  printf '\n'

  if [[ -z "$opencode_password" ]]; then
    printf 'The password cannot be empty.\n' >&2
  elif [[ "$opencode_password" != "$opencode_password_confirm" ]]; then
    printf 'The passwords did not match. Try again.\n' >&2
  else
    break
  fi
done
unset opencode_password_confirm

read -r -s -p 'Paste the Cloudflare Tunnel token: ' tunnel_token
printf '\n'
if [[ -z "$tunnel_token" ]]; then
  printf 'The tunnel token cannot be empty.\n' >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"; unset opencode_username opencode_password tunnel_token' EXIT

username_b64="$(printf '%s' "$opencode_username" | base64 -w 0)"
password_b64="$(printf '%s' "$opencode_password" | base64 -w 0)"
printf 'OPENCODE_SERVER_USERNAME_B64=%s\nOPENCODE_SERVER_PASSWORD_B64=%s\n' \
  "$username_b64" "$password_b64" >"$tmp_dir/opencode-web.env"
chmod 0600 "$tmp_dir/opencode-web.env"
unset username_b64 password_b64

cat >"$tmp_dir/opencode-web.service" <<'UNIT'
[Unit]
Description=OpenCode web interface
Documentation=https://opencode.ai/docs/web/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=lubshad
Group=lubshad
WorkingDirectory=/home/lubshad
Environment=HOME=/home/lubshad
EnvironmentFile=/etc/opencode-web.env
ExecStart=/bin/bash -c 'export OPENCODE_SERVER_USERNAME="$$(printf "%%s" "$$OPENCODE_SERVER_USERNAME_B64" | base64 -d)"; export OPENCODE_SERVER_PASSWORD="$$(printf "%%s" "$$OPENCODE_SERVER_PASSWORD_B64" | base64 -d)"; unset OPENCODE_SERVER_USERNAME_B64 OPENCODE_SERVER_PASSWORD_B64; exec /home/lubshad/.opencode/bin/opencode web --hostname 127.0.0.1 --port 4096 --cors https://opencode.coreaxissolutions.in'
Restart=on-failure
RestartSec=5s
TimeoutStopSec=30s

[Install]
WantedBy=multi-user.target
UNIT

printf 'Installing cloudflared from Cloudflare\047s official repository...\n'
sudo install -d -m 0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o "$tmp_dir/cloudflare-main.gpg"
sudo install -m 0644 "$tmp_dir/cloudflare-main.gpg" /usr/share/keyrings/cloudflare-main.gpg
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' >"$tmp_dir/cloudflared.list"
sudo install -m 0644 "$tmp_dir/cloudflared.list" /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update
sudo apt-get install -y cloudflared

printf 'Installing the OpenCode boot service...\n'
sudo install -o root -g root -m 0600 "$tmp_dir/opencode-web.env" "$ENV_FILE"
sudo install -o root -g root -m 0644 "$tmp_dir/opencode-web.service" "$SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl enable --now opencode-web.service

printf 'Installing the Cloudflare Tunnel boot service...\n'
if systemctl list-unit-files cloudflared.service --no-legend 2>/dev/null | grep -q '^cloudflared.service'; then
  printf 'A cloudflared service already exists; refusing to overwrite it.\n' >&2
  exit 1
fi
sudo cloudflared service install "$tunnel_token"
unset tunnel_token

printf 'Verifying services...\n'
sudo systemctl is-enabled --quiet opencode-web.service
sudo systemctl is-active --quiet opencode-web.service
sudo systemctl is-enabled --quiet cloudflared.service
sudo systemctl is-active --quiet cloudflared.service

http_status="$(curl --silent --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:${OPENCODE_PORT}/")"
if [[ "$http_status" != "401" ]]; then
  printf 'Expected an authenticated response (401) from OpenCode, received HTTP %s.\n' "$http_status" >&2
  exit 1
fi

printf '\nOpenCode is running at %s\n' "$PUBLIC_URL"
printf 'Username: %s\n' "$opencode_username"
printf 'Use the password you entered above.\n'
