---
name: event-based-refresh
description: Use when one frontend component change must refresh data owned by sibling, tab, modal, or feature-local components.
---

Use this skill when a change in one component must refresh data owned by other mounted components, especially when those components are siblings, tab bodies, modals, or feature-local panels that manage their own API fetch state.

## When To Use

- A user action changes shared context such as default role, default sport, active organization, profile reference, selected tenant/site, or permissions.
- Multiple components need to refetch or reset after the change, but prop drilling would cross unrelated feature boundaries.
- Components are mounted at the same time and own their own request state.
- A local UI event is enough; the change does not need cross-tab browser sync, server push, or realtime updates.

## When Not To Use

- Parent and child already share the needed state through normal props.
- A route/navigation change naturally remounts the page.
- A global state store already owns the data and can invalidate it directly.
- The event would replace required backend consistency. Persist the change first, then emit the refresh event.
- Backend work calls external APIs or long-running functions. For backend work, persist local state first and run external work in a background job unless synchronous behavior is explicitly required.

## Pattern

Create one small feature-owned event helper near the domain that owns the context, for example:

```ts
export const PROFILE_CONTEXT_CHANGED_EVENT = "masar:profile-context-changed";

export type ProfileContextChangedDetail = {
  profileId: string;
  referenceDoctype?: string | null;
  referenceName?: string | null;
  changedField: "role" | "sport" | "profile";
};

export function dispatchProfileContextChanged(detail: ProfileContextChangedDetail) {
  if (typeof window === "undefined") return;
  window.dispatchEvent(new CustomEvent(PROFILE_CONTEXT_CHANGED_EVENT, { detail }));
}

export function subscribeProfileContextChanged(
  handler: (detail: ProfileContextChangedDetail) => void,
) {
  if (typeof window === "undefined") return () => undefined;
  const listener = (event: Event) => {
    handler((event as CustomEvent<ProfileContextChangedDetail>).detail);
  };
  window.addEventListener(PROFILE_CONTEXT_CHANGED_EVENT, listener);
  return () => window.removeEventListener(PROFILE_CONTEXT_CHANGED_EVENT, listener);
}
```

## Rules

- Emit only after the mutation succeeds and the local source of truth has been updated.
- Include enough event detail for listeners to fetch the new context without relying on stale props.
- Subscribe in `useEffect` and always return the cleanup function.
- Keep events feature-scoped and named with a stable prefix like `masar:<domain>-<action>`.
- Avoid anonymous string event names scattered across components; import the helper.
- Do not emit continuously from render or effects that run because of the same event. User actions and completed saves are valid emitters.
- Prefer refetching only mounted components. Unmounted tabs should fetch normally when opened.
- For Next.js, event helpers and listeners are client-only; files using hooks or `window` must be client components or guard `typeof window`.
- For Flutter, use the platform's established BLoC/event mechanism in the feature layer; do not create unrelated global singletons when feature BLoCs already own the flow.

## Verification

- Confirm a changed context refreshes each mounted dependent component without navigation.
- Confirm no duplicate continuous requests or refresh loops occur.
- Confirm unmounted components still load fresh data when later opened.
- Run the platform's typecheck/lint for touched files.
