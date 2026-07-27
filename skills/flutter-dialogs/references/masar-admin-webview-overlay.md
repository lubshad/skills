# Masar Admin WebView Overlay Guard

Masar Admin renders PDF previews as iframe-backed `HtmlElementView` platform views. Dialogs above that viewer must use the shared guard so the iframe cannot receive clicks or retain browser focus through the dialog.

Import the shared core widget:

```dart
import '../../../../core/widgets/webview_overlay_guard.dart';
```

Wrap the dialog content, not the screen or PDF viewer:

```dart
showDialog<void>(
  context: context,
  builder: (dialogContext) => WebViewOverlayGuard(
    child: AlertDialog(
      title: const Text('Approve Profile?'),
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

`WebViewOverlayGuard` is located at `flutter_apps/masar_admin/lib/core/widgets/webview_overlay_guard.dart`. It uses `PointerInterceptor`, clears the active web element, and moves Flutter focus into the dialog without unmounting the underlying PDF iframe.
