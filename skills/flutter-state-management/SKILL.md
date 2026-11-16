---
name: flutter-state-management
description: Use when changing Flutter BLoCs, Cubits, events, states, repositories, or async UI state.
---

# Flutter State

Use **BLoC**, one per feature concern (separate listing/form concerns, not a feature-wide god BLoC). Store `<name>_bloc.dart`, `<name>_event.dart`, and `<name>_state.dart` in `features/<name>/bloc/`.

- Events name actions/triggers (`LoadPlayers`, `SearchChanged`); states name explicit outcomes (`PlayersLoading`, `PlayersLoaded`, `PlayersError`) rather than less-clear status enums.
- BLoCs own business/data flow and call repositories, which call the API client. UI responds to states with navigation, dialogs, and toasts.
- Provide at screen scope when pushing screens; app-root providers are for truly global concerns such as auth. `BlocProvider` auto-disposes; manually created BLoCs must be closed.

## Provider context

A screen's `State.context` is above providers created by its own `build`. Read BLoCs from descendant `BlocBuilder`, `BlocConsumer`, `BlocListener`, `Builder`, or child contexts. Pass that context into action/filter/pagination/refresh/save/delete/navigation/dialog callbacks.

Capture the BLoC before awaiting a dialog/route, then check `context.mounted` and the result before dispatch. For complex screens, extract a private child below `BlocProvider` so its context can safely read the BLoC.

## Verification

Check repository boundaries, provider ancestry, awaited callback safety, explicit outcomes, and disposal.
