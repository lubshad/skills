# Platform Button Implementations

## Flutter

For actions that should dismiss the keyboard, put the focus change before the action:

```dart
FocusManager.instance.primaryFocus?.unfocus();
```

For meaningful touch confirmations, use Flutter haptics:

```dart
import 'package:flutter/services.dart';

HapticFeedback.lightImpact();
```

Shared Flutter button widgets may provide this behavior when it is appropriate for every use of that widget. Do not make inline controls vibrate or blur focus by default.

## Next.js / React

Blur only when the action changes the input context:

```ts
if (document.activeElement instanceof HTMLElement) {
  document.activeElement.blur();
}
```

Browser vibration is optional and support varies. Do not require it for web or keyboard-triggered interactions.
