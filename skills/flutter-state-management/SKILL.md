---
name: flutter-state-management
description: Use when adding or modifying Flutter BLoC, Cubit, state classes, events, repositories, or async UI state.
---

Follow these state management rules strictly when working on Flutter code.

## Pattern

Use **BLoC** (Business Logic Component) for all state management.

## Structure

Each feature's BLoC lives in its own folder:

```
features/<name>/bloc/
├── <name>_bloc.dart        # BLoC class
├── <name>_event.dart       # Event definitions
└── <name>_state.dart       # State definitions
```

## Rules

- **One BLoC per feature concern.** A listing screen gets its own BLoC; a form screen gets its own BLoC. Do not create a single "god BLoC" for an entire feature.
- **Events are inputs.** Name them as user actions or system triggers: `LoadPlayers`, `DeletePlayer`, `SearchChanged`.
- **States are outputs.** Use explicit states: `PlayersLoading`, `PlayersLoaded`, `PlayersError`. Avoid generic "status" enums when distinct state classes are clearer.
- **No UI logic in BLoCs.** BLoCs handle business logic and data flow only. Navigation, dialogs, and toasts are triggered by the UI layer in response to state changes.
- **No direct API calls in BLoCs.** BLoCs call repositories; repositories call the API client.
- **Provide BLoCs at the screen level.** Use `BlocProvider` when pushing a screen, not at the app root (unless the BLoC is truly global like auth).
- **Dispose properly.** BLoCs provided via `BlocProvider` auto-dispose. Never create BLoCs manually without closing them.

## Provider Context Safety

- When a screen creates a `BlocProvider` in its own `build` method, never call `context.read<FeatureBloc>()` from the `State.context` or from methods that implicitly use it. That context is above the provider.
- Read feature BLoCs from the `BuildContext` supplied by `BlocBuilder`, `BlocConsumer`, `BlocListener`, `Builder`, or child widgets below the provider.
- Pass the bloc-aware `BuildContext` into callbacks that dispatch events, show dialogs, navigate, filter, paginate, refresh, save, or delete.
- If a callback awaits a dialog or route before dispatching, capture the bloc before the `await`:

  ```dart
  Future<void> _confirmDelete(BuildContext context, Item item) async {
    final bloc = context.read<ItemsBloc>();
    final confirmed = await showDialog<bool>(context: context, builder: ...);
    if (!context.mounted || confirmed != true) return;
    bloc.add(DeleteItem(item.id));
  }
  ```

- Prefer extracting a private child view under `BlocProvider` for complex screens. The child view's `build` context can safely read the screen-level bloc.
