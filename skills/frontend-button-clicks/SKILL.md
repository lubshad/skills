# Frontend Button Clicks

This skill defines the mandatory sequence of events that must occur on *every* primary and secondary button click across all frontend platforms.

## Core Rules

Whenever a user taps or clicks an actionable button, the following sequence MUST be executed before the primary action logic begins:

1. **Unfocus (Remove Keyboard/Input Focus):**
   - The application must explicitly drop focus from any currently active text field or input. 
   - *Why:* This ensures the software keyboard closes on mobile devices, preventing it from obscuring loading states, bottom sheets, or navigation changes that result from the button click.

2. **Haptic Feedback:**
   - The application must trigger a light or medium haptic feedback (vibration) immediately upon the button press.
   - *Why:* Provides tactile confirmation to the user that the system registered the input, reducing duplicate taps on slow networks.

3. **Execute Action:**
   - Proceed with the button's intended logic (e.g., API call, navigation, state change).

---

## Platform Implementations

### Flutter Adapter
When implementing this in Flutter, use the following patterns:

**1. Unfocusing:**
Always call this at the very top of your `onPressed` or `onTap` callback:
```dart
FocusManager.instance.primaryFocus?.unfocus();
```

**2. Haptics:**
Use the standard Flutter services for haptics. Typically, a light impact is preferred for standard buttons:
```dart
import 'package:flutter/services.dart';

HapticFeedback.lightImpact(); // or mediumImpact() for heavier actions like Submit
```

**Combined Example:**
```dart
ElevatedButton(
  onPressed: () {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.lightImpact();
    
    // ... proceed with form submission or action
    context.read<MyBloc>().add(SubmitEvent());
  },
  child: Text('Submit'),
)
```
*(Note: If creating a reusable custom button widget in `lib/core/widgets/`, bake this logic directly into the custom widget's generic `onPressed` handler so developers get it for free).*

### Next.js / React Web Adapter
When implementing this in Web/Next.js:

**1. Unfocusing:**
```typescript
if (document.activeElement instanceof HTMLElement) {
  document.activeElement.blur();
}
```

**2. Haptics:**
Web support for haptics is limited, but can be implemented using the Navigator API where supported:
```typescript
if (typeof navigator !== 'undefined' && navigator.vibrate) {
  navigator.vibrate(50); // 50ms light tap
}
```
