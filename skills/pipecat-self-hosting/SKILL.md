---
name: pipecat-self-hosting
description: Use when deploying, fixing, or reviewing self-hosted Pipecat bots under uv/systemd or existing Docker Compose.
---

# Pipecat Self-Hosting

Default to `uv run bot.py` under named systemd, released through Actions/SSH; retain Docker only when existing or explicitly required. Pipecat Cloud is separate.

Before configuration/release, read [the hosting contract](HOSTING.md) and `github-actions-deployment.md` when CI/promotion is involved. The contract owns exact service settings, provisioning, bounded commands/rollback, Docker diagnostics, and Xealth environment exceptions.

## Invariants

- Preserve approved production-only versus dual-target promotion interfaces, separate targets/backups and expected-OID leases. Missing target/provisioning requires approval, not fallback to production.
- Existing single-file releases sync only `server/bot.py`; keep env/venv/dependencies server-managed unless explicitly changed. New imports/dependencies require deliberate contract expansion.
- Validate target first, upload temporary file, retain `bot.py.previous`, atomically replace, and restart nonblocking. Bound SSH/rsync/curl/polling independently, with phase logs and finite job concurrency.
- Verify service plus local/public `/status`; restore prior file on workflow-managed failure. No endless journal-follow or leaked env/provider keys.
- Docker binds `0.0.0.0`, uses locked image dependencies rather than host venv, excludes caches/secrets, and maps local Frappe/MCP host gateways where needed.
- Restart interrupts active voice sessions; do not claim zero downtime.

## Verification

Use contract script/branch/YAML/timeout/key/rollback checks. Separate local/public health from actual transport behavior; Docker host connectivity precedes external webhook tests. Configuration edits authorize no production push.
