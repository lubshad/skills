---
name: frappe-backup
description: Use when changing or explaining Frappe remote backups, downloads, local restores, or site-sync scripts.
---

# Frappe Backup and Restore

Prefer `.agents/scripts/sync_server_data.sh`, dry-run by default; mutations require `--execute` and authorized targets. Before changing/running sync or restore, read [the backup contract](BACKUP-RESTORE.md) for flags/defaults, matching config/database backups, archive layout, and legacy scripts.

## Invariants

- Resolve Bench root, site, key, and destination before mutations; a script under `sites/<site>/` walks up two levels, not one.
- Restore database plus requested public/private files; strip archive nesting so files land directly in the local site file directories.
- Sync encryption key only from configuration matching the selected DB prefix; explicitly select other application keys. Protect local infrastructure/site controls and common config. Invalid/missing selected values fail before restore without leaking values.
- Keep private downloads/recovery config copies, merge atomically after DB restore and before migration, and preserve unselected local settings. `--skip-config` is explicit, not a silent fallback.
- Preserve existing workflow and fail clearly for absent keys/backups/paths. No unrelated destructive remote operations.

## Verification

Syntax-check and run offline config tests from the contract. Before actual restore confirm selected target/key; afterward verify DB/file paths, migration/cache steps, site startup, and attachment reads. This documentation migration authorizes no backup or restore execution.
