# Frappe test isolation

## Choose before provisioning

Verify imported app/dependency paths and SHAs, local modifications, installation hooks, patches, and external effects. A site isolates data, not code, Python, Redis, workers, or files. A worktree working directory does not select Frappe imports.

**Default: a temporary site in the existing Bench**, with local MariaDB and a dedicated disposable database/user, when site creation is authorized. Watchers follow `.automation/local-bench-testing.md`. Reuse existing scoped approval; watcher approval does not cover unrelated interactive work.

Use a separate temporary Bench only for a concrete isolation need: different code/dependency revisions, baseline-to-head migration testing, or effects unsafe in the shared environment. Record the reason before proposing/requesting it. A fresh head install is not migration evidence. Do not switch, patch, or relink shared apps, install shared dependencies, or restart shared services to fit tests.

A separate Bench may reuse local MariaDB with a disposable database/user; a private database daemon is not the default. Follow `.automation/storage.md` for disk-backed scratch. Private Redis/processes need applicable approval when shared-service safety is uncertain.

## Ownership and cleanup

For authorized exclusive creation of a verified absent private Bench directory, check its target and parents. Unrelated protected processes do not establish ownership of that directory. Preserve existing/interrupted resources; apply strict identity/process checks to involved resources. Ambiguous ownership remains a blocker.

Protect existing sites, mock outbound effects, disable new-site scheduling/email, avoid shared-worker jobs, and record ownership/evidence privately. These rules grant no unrelated site creation/deletion or infrastructure permission.

When disposal is authorized (including the four installed watchers), automatically clean up proven-owned test sites, databases, users, and files on success or failure. Preserve logs and verify absence. Remove owned drop-site archives too; do not force-drop unknown resources. Record interrupted cleanup for scoped reconciliation.

## Watcher database provisioning

Follow `.automation/database-access.md`. Load `PR_WATCH_DB_ADMIN_USER` / `PR_WATCH_DB_ADMIN_PASSWORD` from private env for trusted helpers only, not as site connection overrides. Preallocate scoped databases/users, bootstrap with `setup_db=False`, and run apps/tests without admin settings.

Keep root credentials out of shared/site configuration, arguments, prompts, and logs. Require guarded ownership-based disposal and durable evidence. Same-UID private files are not a hostile-code security boundary.
