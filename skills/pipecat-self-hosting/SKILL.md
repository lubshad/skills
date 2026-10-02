---
name: pipecat-self-hosting
description: Use when deploying, fixing, or reviewing self-hosted Pipecat bots, with uv and systemd as the default production model and Docker Compose for existing containerized bots.
---

# Pipecat Self-Hosting

Use this skill for every self-hosted Pipecat deployment. New production bots run directly with `uv` under systemd. Use the Docker guidance only when a repository already uses Docker or Docker Compose. Read `github-actions-deployment.md` alongside this skill whenever GitHub Actions or production branch promotion is involved.

## Production Model

- **Default:** `uv run bot.py` under a named systemd service, released through GitHub Actions over SSH.
- **Existing Docker deployments:** retain Docker Compose only when the bot is already containerized or Docker is explicitly required.
- Pipecat Cloud is a separate hosted option and is not covered by this self-hosting standard.

## Systemd Deployments

### Deployment Contracts

### Explicit dual-environment deployments

- For migrated bots such as Xealth Voice Assistant, `./deploy` promotes `development` after backing it up to `development-backup`, and `./deploy --prod` promotes `production` after backing it up to `production-backup`.
- Require clean named source branches, reject all four deployment/backup branches, and use captured expected-OID leases for both ref updates. Missing targets require approved initialization; never push target refs as routine verification.
- Add a separate development workflow with its own environment/concurrency and matching-ref guard. Keep the same bounded upload, atomic replacement, non-blocking restart, local/public health, and rollback lifecycle. Do not copy `.env` or provider keys.
- Xealth dev host/public URL: `twilio-dev.xealth.ca`; runtime user/path/service remain `dockeruser`, `/home/dockeruser/xealth-voice-assistant`, and `xealth-voice-assistant.service` on a separate dev server. Server-managed `MCP_URL` must use `backend-dev.xealth.ca` and `PUBLIC_HOST` must use `twilio-dev.xealth.ca`.
- Development variables: `XEALTH_DEV_SSH_HOST`, `XEALTH_DEV_SSH_USER`, optional `XEALTH_DEV_SSH_PORT`, `XEALTH_DEV_REMOTE_PATH`, `XEALTH_DEV_SERVICE_NAME`, `XEALTH_DEV_PUBLIC_URL`. Xealth intentionally reuses its existing repository `XEALTH_SSH_PRIVATE_KEY` secret as requested; authorization on the dev host must be verified before release.
- Never reuse the same service/path on the same physical host for both targets. Host provisioning is separate; missing users/services/runtime or GitHub environment-management permission must be reported rather than silently deploying to production.
- The production-only reference/defaults below apply to bots not explicitly migrated. The dual-target example is `pipecat_bots/xealth-voice-assistant/deploy`; preserve other bots' existing contracts.

### Existing production-only contract

- Keep `.env`, `.venv`, `pyproject.toml`, and `uv.lock` server-managed unless a release explicitly changes dependencies.
- Routine releases sync only `server/bot.py` to the remote runtime directory as `bot.py`.
- Deploy from a dedicated `production` branch and retain `workflow_dispatch` for retries.
- Existing production-only helpers promote to `production` by default and back it up to `production-backup`; migrated two-target bots use the contract above.
- Planned interface: `./deploy --internaltest` will promote to `internaltest` after backing up that branch's previous ref to `internaltest-backup`. The flag is not currently implemented; add support only when requested, with a matching workflow and target-specific safety guards, while retaining the default production behavior.
- Copy `../github-actions-deployment/reference/pipecat-deploy` to the repository root as `deploy` to back up and promote production.
- Never commit runtime provider keys or place the production `.env` in GitHub Actions.

The single-file release contract is intentional. If `bot.py` starts importing new local modules or requires dependency changes, expand the deployment contract explicitly before release rather than silently copying an incomplete source tree.

### Server Provisioning

Provision once:

- A dedicated Linux runtime user with SSH key access and a stable application directory.
- `uv`, `pyproject.toml`, `uv.lock`, a synced `.venv`, and `.env` in that directory.
- A systemd service whose `WorkingDirectory` is the application directory.
- Passwordless sudo limited to restart, state inspection, status, and journal access for that service.
- Nginx and TLS configured separately from the deployment workflow.

```ini
[Unit]
Description=Pipecat Voice Assistant
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=<runtime-user>
WorkingDirectory=<remote-path>
ExecStart=/home/<runtime-user>/.local/bin/uv run --no-sync bot.py
Restart=always
RestartSec=5
SuccessExitStatus=143
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
```

### GitHub Actions Deployment

Start from `../github-actions-deployment/reference/pipecat-systemd-production.yml` and `../github-actions-deployment/reference/pipecat-deploy`.

The workflow must validate syntax and required secrets, install a step-scoped SSH key, and check the remote directory, `bot.py`, and `.env` before mutation. Upload to a temporary remote filename, retain `bot.py.previous`, atomically replace the file, then use `systemctl --no-block restart`.

Poll both `systemctl is-active` and local Pipecat `/status`, then verify public HTTPS `/status`. On failure, print bounded systemd and journal output, restore `bot.py.previous`, and restart.

### Bounded Operations

Every network or service operation needs its own timeout:

- SSH: `ConnectTimeout`, `ConnectionAttempts`, `ServerAliveInterval`, and `ServerAliveCountMax`.
- Rsync: `--timeout`.
- Curl: `--connect-timeout` and `--max-time`.
- Restart: `systemctl --no-block restart`, followed by polling.
- Workflow: finite `timeout-minutes` and production concurrency.

Print phase markers before preflight, upload, restart, local health, and public health so GitHub's log identifies a blocked operation.

## Docker Compose Deployments

Use this section only for a bot that is already deployed with Docker or Docker Compose.

- Pipecat must bind to all container interfaces: `uv run --no-sync bot.py --host 0.0.0.0`.
- `localhost` inside a container is the container itself, not the host.
- Do not copy a host `.venv` into a Linux image. Build from `pyproject.toml` and `uv.lock`.
- When Docker build context is `server/`, add `server/.dockerignore` containing `.venv`, `__pycache__`, `.ruff_cache`, `*.pyc`, `*.pyo`, and `.env`.
- If the container calls a local Frappe or MCP hostname, add an `extra_hosts` host-gateway mapping for that hostname.

```dockerfile
CMD ["uv", "run", "--no-sync", "bot.py", "--host", "0.0.0.0"]
```

```yaml
services:
  pipecat-app:
    ports:
      - "7860:7860"
    extra_hosts:
      - "xealth.localhost:host-gateway"
```

Container diagnosis:

- Uvicorn reporting `http://localhost:7860`: fix the bind address to `0.0.0.0`.
- Host cannot connect: inspect `docker compose ps`, port publishing, and `curl http://localhost:7860/status` before ngrok or Twilio.
- Bot crashes while calling a local Frappe/MCP URL: add the needed host-gateway mapping.
- Image build context is unexpectedly large: exclude `.venv` and caches.

## Health And Diagnostics

Pipecat Runner exposes local health at:

```text
http://127.0.0.1:7860/status
```

A ready response resembles:

```json
{"status":"ready","transports":["webrtc","twilio","websocket"]}
```

The transport list varies. Require HTTP success, not a fixed response body.

- Connection refused: service/container is stopped, starting, or bound to another port.
- Curl timeout after connection: the process or event loop is not serving requests.
- `502 Bad Gateway` from Nginx: the upstream was unavailable during restart or crashed after health.
- systemd `status=1/FAILURE`: inspect the Python traceback with `journalctl`; this is not a missing health route.
- systemd `status=143`: add `SuccessExitStatus=143` when shutdown was graceful.

Use bounded logs in CI:

```bash
sudo -n systemctl status <service> --no-pager
sudo -n journalctl -u <service> -n 100 --no-pager
```

Do not use `journalctl -f` or `docker compose logs -f` in Actions.

## Release Flow

Initialize `production` and `production-backup` from the intended baseline. Normal systemd releases run `./deploy` from a clean development or release branch. The production push is the only deployment trigger.

Systemd restart interrupts active voice sessions. Schedule releases appropriately; this model is not zero-downtime.

## Verification

- Run `bash -n deploy` and test its dirty, detached, `production`, and `production-backup` refusal paths.
- Parse workflow YAML and syntax-check every multiline Bash block.
- Confirm SSH, rsync, and curl operations are bounded.
- Confirm private keys are step-scoped and removed with `if: always()`.
- Confirm `.env` is checked but never copied or printed.
- Confirm rollback restores the prior `bot.py`.
- Confirm local and public `/status` endpoints return success.
- For Docker, confirm `0.0.0.0` binding and host access before testing external webhooks.
