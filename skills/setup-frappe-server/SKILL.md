---
name: setup-frappe-server
description: Use when configuring Frappe servers, Bench/sites/apps/services, provisioning scripts, or authorized local test sites.
---

# Frappe Server Setup

**Local tests and remote provisioning are separate workflows.** Read [the setup runbook](SERVER-SETUP.md) before choosing or modifying either. It retains current script flags/defaults, idempotency, Xealth setup, service/SSL ordering, and safety checks. Skill loading authorizes no provisioning.

## Local test sites

Use existing MariaDB only with applicable scoped approval and `.automation/local-bench-testing.md`/`.automation/database-access.md` for watchers. Verify exact imported source/dependencies; sites share code/services. No root credentials in apps/tests/argv/logs, auth changes, shared app relinking, production data, or backup restores. Trusted helpers preallocate scoped DB/users and bootstrap with `setup_db=False`. Locks/ownership govern automatic disposal of proven-owned disposable sites/DB/users/files/archives after logs are saved.

## Remote provisioning

Use local SSH orchestrator `.agents/scripts/setup_frappe_server.sh` on approved Ubuntu/Debian targets, dry-run first and explicit `--execute`. Review existing-production backups/output. Resolve host/site/password/email/key/user/branch/paths/apps/swap settings; never commit real passwords.

Preserve guard-before-mutation idempotency, direct Bench-user SSH access, dependencies/tool PATH, MariaDB setup, production Redis/supervisor before migration, nginx and SSL verification. Xealth wrapper creates/skips its remote app instead of cloning private GitHub or syncing local code during provisioning; subsequent deployment is separate.

## Verification

Run shell syntax/offline checks for changed scripts. Authorized execution verifies Bench/Redis/supervisor/nginx/site health, intended SSH access, HTTPS, and no exposed credentials. Never add reset/drop/destructive cleanup without explicit scope.
