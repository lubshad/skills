---
name: flutter-dialogs
description: Use when creating, editing, or reviewing Flutter dialogs and their close, submit, confirmation, or BLoC actions.
---

# Flutter Dialogs

**Dialog context closes; screen dependencies act.** Capture BLoCs before `showDialog`, name its builder context `dialogContext`, and close with `Navigator.of(dialogContext).pop()`. Then dispatch through the captured BLoC or navigate through the parent context/routing service.

```dart
final bloc = context.read<ApprovalsBloc>();
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(dialogContext).pop();
          bloc.add(ApproveProfile());
        },
        child: const Text('Approve'),
      ),
    ],
  ),
);
```

In `StatefulBuilder`, use `builder: (_, setState)` and retain the outer dialog context. Avoid shadowed `context`, outer-screen `Navigator.pop(context)`, or provider reads from the dialog unless provider ancestry is deliberately verified. Nested dialogs close only the newest route. Fullscreen dialog close buttons use the same dialog context, not inner Scaffold contexts.

## Over platform views

For overlays above web `HtmlElementView`, iframe PDFs, WebViews, maps, or native/HTML views, wrap content in shared `WebViewOverlayGuard`. It uses `PointerInterceptor`, blurs the browser element, and focuses the overlay after the first frame. Keep underlying views mounted to preserve content/scroll state. Ordinary Flutter-only dialogs need no guard.

Read `references/masar-admin-webview-overlay.md` for the concrete core-widget path and usage.

## Verification

Search changed dialogs for outer `Navigator.pop(context)` and shadowing `builder: (context)`/`(context, setState)`. Check route dismissal and provider ownership. Run `dart format` and `flutter analyze`.
