---
name: api-parallelization
description: Use when adding, reviewing, or optimizing multiple independent API calls or remote loads.
---

# Parallel API Loads

**Dependency before concurrency.** Classify consecutive awaits:

- Dependent: later work needs a result, refreshed auth, persisted state, or completed side effect; keep ordered.
- Independent: known inputs and no shared mutation; start/await together.
- Enrichment: load base records, then group/batch follow-ups rather than per-item requests.

Keep ordered writes, workflow/payment/destructive operations, and rate-limited calls sequential unless the contract permits concurrency. Frappe frontend bulk deletion uses native `frappe.desk.reportview.delete_items`, not destructive request loops/parallel calls.

## Platform execution

- Flutter calls stay in repositories, not widgets/BLoCs. Start futures before awaiting; use Dart record `.wait` for differing types when SDK supports it, `Future.wait` for homogeneous lists. Dependent profile fetch precedes parallel profile-ID lookups.
- TypeScript uses `Promise.all` for independent helpers/routes; bundle related browser lookups into one route. SSR waits only for first-paint data (`nextjs-page-performance.md`).
- Frappe outbound/long work first reads `frappe-async-external-apis.md`: persist/enqueue, not request blocking. Jobs may parallelize independent reads only with provider support and clear error handling. Prefer `in`-filter batching over per-record calls.

Required-data failures fail the combined operation through normal handlers. Isolate optional enrichment failures without discarding base data; never hide required failures for parallelism.

## Verification

Check real dependencies for serial awaits, batched enrichment, ordered side-effect safety, and accurate loading/refresh/retry states.
