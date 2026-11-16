---
name: frappe-deployment
description: Use when configuring or explaining Frappe GitHub deployments, branch promotion, legacy sync, or remote Bench lifecycle.
---

# Frappe Deployment

**Promotion triggers CI; CI deploys.** Root executable `deploy` backs up/promotes protected refs only. It does not SSH, sync, migrate, or restart. New deployments use workflows, not new `sync.sh` wrappers; preserve existing legacy scripts unless migration/cleanup is requested.

Read `github-actions-deployment.md` and [the Frappe deployment contract](DEPLOYMENT-CONTRACT.md) before changing helpers/workflows or running a release. The contract retains exact branch/lease rules, credential isolation, first-install steps, project exceptions, and checks.

## Lifecycle

Validate selected target/config and remote Bench → sync only app source with metadata/env/cache/credential exclusions → editable pip install → safely normalize `sites/apps.txt` → install app only if absent → approved backup/preflight → migrate → app assets only when configured → restart → HTTPS `/api/method/frappe.ping` with `message=pong`.

Keep deployment keys step-scoped, expected-OID leases, finite non-cancelling migration concurrency, explicit dev/prod configuration, and no private keys in Git. Verify actual GitHub protection rules rather than assuming paid-plan gates exist. Dependencies belong in modern `pyproject.toml`, not normal app requirements files.

Preserve repository-specific exceptions: Sync deployment interfaces/build policy, Xealth setup/targets, and Masar/MCAL environments are in the contract and `project-connections.md`; generic examples cannot override them.

## Verification

Use offline syntax/YAML and disposable-ref guards without deployment pushes. Authorized live validation separately checks package/site install, migrations/services/nginx and intended HTTPS health. Workflow fixes need a new run at the corrected SHA; preserve failed history and reconcile dependents without repeating bumps or unrelated releases.
