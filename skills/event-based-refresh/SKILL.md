---
name: event-based-refresh
description: Use when saved context changes must refresh independently loaded sibling, tab, modal, or feature components.
---

# Feature Refresh Events

Use a local feature event when mounted components own separate request state and context changes (role/sport/organization/profile/tenant/site/permissions) would otherwise require unrelated prop drilling. Not for cross-tab sync/server push, existing shared props/store invalidation, or natural route remounts.

**Persist, then emit.** After mutation success and local source update, publish enough new context to avoid stale listener props. Events never replace backend consistency; outbound/long backend work persists/enqueues unless sync is explicitly required.

## Contract

Create one feature-owned typed helper with a stable name (`masar:<domain>-<action>`), dispatch, and subscribe/unsubscribe functions—not scattered anonymous strings. For example, profile context detail carries profile ID, optional reference DocType/name, and changed role/sport/profile field.

Browser helper guards `typeof window`; dispatch a typed `CustomEvent`, subscribe in `useEffect`, and return listener cleanup. Hooks/browser users are client components. Emit from actions/completed saves, not render or self-triggering effects. Refetch mounted dependents; unopened tabs load normally when opened.

Flutter uses feature BLoC/events, not unrelated global singletons when feature state already owns the flow.

## Verification

Change context and confirm all mounted dependents refresh without navigation, no duplicate requests/loops, and later-opened tabs load fresh. Run platform typecheck/lint for changed files.
