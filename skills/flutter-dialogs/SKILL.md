---
name: flutter-dialogs
description: Use when creating, editing, or reviewing Flutter dialogs, AlertDialog, showDialog, StatefulBuilder dialogs, modal routes, fullscreen dialogs, and any dialog button that pops, closes, submits, confirms, cancels, approves, rejects, or dispatches BLoC actions.
---

# Flutter Dialogs

Follow these rules for Flutter dialogs and modal route actions.

## Core Rule

- Use the dialog route context to close the dialog.
- Use the parent screen context, or captured dependencies from it, to dispatch actions.
- Never call `Navigator.pop(context)` from an outer screen context inside a dialog action.
- Never rely on a shadowed `context` from nested builders when the action needs both route dismissal and BLoC/state access.

## Required Pattern

Capture dependencies before `showDialog`, name the dialog builder context `dialogContext`, and close with `Navigator.of(dialogContext).pop()`.

```dart
void _confirmApprove(BuildContext context) {
  final approvalsBloc = context.read<ApprovalsBloc>();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Approve Profile?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            approvalsBloc.add(ApproveProfile());
          },
          child: const Text('Approve'),
        ),
      ],
    ),
  );
}
```

## StatefulBuilder Dialogs

For dialogs using `StatefulBuilder`, keep the outer dialog context available and avoid naming the inner builder context `context`.

```dart
showDialog(
  context: context,
  builder: (dialogContext) => StatefulBuilder(
    builder: (_, setState) => AlertDialog(
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  ),
);
```

## BLoC And Provider Access

- If a dialog button dispatches a BLoC event, capture the BLoC before opening the dialog: `final bloc = context.read<MyBloc>();`.
- Dispatch through the captured BLoC after closing the dialog.
- Do not call `dialogContext.read<MyBloc>()` unless the provider is intentionally above the dialog route and this has been verified.

## Navigator Rules

- Dialog dismiss: `Navigator.of(dialogContext).pop()`.
- Screen navigation after dialog dismissal: first close the dialog with `dialogContext`, then navigate using the parent screen context or a routing service.
- Nested dialogs: close only the topmost dialog using the most recent dialog's `dialogContext`.
- Fullscreen dialogs created with `showDialog` follow the same rule; their close button must use `dialogContext`, not an inner `Scaffold` builder context.

## Anti-Patterns

Do not use these patterns in dialog actions:

```dart
Navigator.pop(context);
context.read<MyBloc>().add(MyAction());
```

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);
```

```dart
StatefulBuilder(
  builder: (context, setState) => AlertDialog(...),
);
```

## Verification

- Search touched Flutter files for `Navigator.pop(context)` and replace dialog dismissals with `Navigator.of(dialogContext).pop()`.
- Search touched dialog code for `builder: (context)` or `builder: (context, setState)` and rename contexts to avoid shadowing.
- Run `dart format` on touched Dart files.
- Run `flutter analyze` for Flutter apps after dialog code changes.
