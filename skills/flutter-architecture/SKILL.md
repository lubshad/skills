---
name: flutter-architecture
description: Use when structuring Flutter projects, creating features, or changing module boundaries.
---

# Flutter Architecture

**Feature first.** Each `lib/features/<feature>/` owns `bloc/`, `data/`, `models/`, `screens/`, and `widgets/`. Cross-feature helpers, widgets, config, and exceptions belong in `lib/core/`; features do not import each other's internals.

## Files and services

- One public widget per snake_case file matching its class (`PlayerCard` → `player_card.dart`).
- Reusable methods live in helper classes. Wrap `shared_preferences` in a helper; widgets/BLoCs never call it directly. Format exceptions through the custom human-readable formatter.
- `main_dev.dart` and `main_prod.dart` load separate API URLs, flags, and debug settings.
- Give `MaterialApp` a `navigatorKey` for helpers needing navigation/dialog/toast context outside the widget tree.

## Navigation shell

Keep sidebar/body navigators in `features/navigation/`; the shell contains no top bar. Shared admin appbars belong only to first-level destinations (dashboard/listing/index). Nested detail/create/edit/profile/forms use local Back/Save/Reset/Refresh/workflow headers without global user/session details.

Shared top bars exclude global search, date ranges, notifications, and desktop collapse controls unless a first-level page owns the feature. Sidebar renders desktop collapse/expand; shell may own its state/persistence. A narrow-layout page may expose a drawer opener.

Use multiple body navigators. Production keeps them mounted in an `IndexedStack` to retain nested routes/state. Debug mounts only the selected navigator through a small child keyed by index.

`SuperAdminSidebarMapper` maps valid `WorkspaceSidebar` items to `NavigationDestinationItem`. Reject null/empty input, not sidebar names: Super Admin, Operational Admin, and Federation Admin share targets.

## Verification

Check feature boundaries, file naming, shell/header ownership, and debug/production navigator lifetime against these rules.
