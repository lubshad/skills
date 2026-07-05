---
name: api-parallelization
description: Use when adding, reviewing, or optimizing multiple API calls or remote data loads that can run independently.
---

Follow these rules when adding, reviewing, or changing code that performs multiple API calls or remote data loads.

## Core Rule

- Run independent API calls in parallel wherever possible.
- Keep calls in series only when a later call needs data, auth state, persisted local state, or side effects from an earlier call.
- Do not parallelize ordered writes, workflow actions, payment operations, destructive actions, or rate-limited external calls unless the API contract explicitly supports it.
- For frontend bulk actions (like delete) on Frappe backends, always use the native bulk RPC endpoint (e.g., `frappe.desk.reportview.delete_items`) to handle operations atomically on the server instead of looping through individual API calls or parallelizing destructive calls.

## Dependency Check

Before leaving multiple awaits in a row, classify each call:

- **Dependent:** call B needs call A's result, refreshed credentials, persisted local fields, or a completed mutation. Keep A before B.
- **Independent:** calls use already-known inputs and do not mutate shared server state. Start them together and await them together.
- **Optional enrichment:** fetch the base data first, then fetch all enrichment data in one grouped/batched follow-up where possible.

## Flutter / Dart Pattern

- Keep API calls inside repositories, not widgets or BLoCs.
- Start independent repository futures before awaiting results.
- Prefer Dart record `.wait` when the result types differ and the project SDK supports Dart 3 records.
- Use `Future.wait` for homogeneous lists.

```dart
final (profile, settings) = await (
  repository.getProfile(),
  repository.getSettings(),
).wait;
```

For mixed dependency chains, keep only the dependency in series:

```dart
final employee = await repository.refreshEmployeeProfile();
final (shifts, leaves) = await (
  repository.getUpcomingShifts(employee.id),
  repository.getLeaveApplications(employee.id),
).wait;
```

## Next.js / TypeScript Pattern

- Use `Promise.all` for independent server helpers or API route work.
- Do not block a server page render on data not needed for first paint; read `nextjs-page-performance.md`.
- Prefer one bundled API route for related client-side lookup data instead of many client requests.

```ts
const [roles, sports, countries] = await Promise.all([
  getRoles(),
  getSports(),
  getCountries(),
]);
```

## Frappe / Python Pattern

- For outbound external APIs or long-running work, read `frappe-async-external-apis.md` first: persist local state and enqueue background work instead of blocking the request.
- Inside a background job, independent remote reads may run concurrently only when the provider allows it and error handling remains clear.
- Prefer batching with Frappe filters such as `["name", "in", names]` over N per-record API calls.

## Error Handling

- If all data is required, fail the combined operation normally and let the existing BLoC, route, or handler show the error.
- If one call is optional, isolate its failure so it does not discard required data.
- Do not hide failures for required data just to preserve parallelism.

## Review Checklist

- Consecutive `await` calls have a real dependency, or they are parallelized.
- Enrichment calls are batched instead of run per item.
- Mutations with ordering, idempotency, or side-effect constraints remain sequential.
- Loading, refreshing, and retry states still represent the combined operation accurately.
