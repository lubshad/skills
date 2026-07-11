---
name: frontend-button-clicks
description: Use when implementing button clicks, form submission, or generic user actions that may need focus management or haptic feedback.
---

# Frontend Button Clicks

This skill defines contextual interaction rules for button clicks across frontend platforms.

## Core Rules

For a touch-first action that submits a form, changes context, opens a sheet, or navigates away, use the following sequence when it improves the interaction:

1. **Unfocus (Remove Keyboard/Input Focus):**
    - Explicitly drop focus only when the action makes the active input or keyboard irrelevant.
   - *Why:* This ensures the software keyboard closes on mobile devices, preventing it from obscuring loading states, bottom sheets, or navigation changes that result from the button click.

2. **Haptic Feedback:**
    - Trigger light or medium haptic feedback on supported touch devices for meaningful confirmations such as submit, save, destructive confirmation, or navigation.
   - *Why:* Provides tactile confirmation to the user that the system registered the input, reducing duplicate taps on slow networks.

3. **Execute Action:**
    - Proceed with the button's intended logic (for example, an API call, navigation, or state change).

Do not blur keyboard-focused controls for inline actions such as toggles, pagination, filters, or retry. Do not require vibration for web, keyboard activation, or high-frequency controls. Preserve visible keyboard focus unless the interaction deliberately moves the user elsewhere.

## Implementation References

- Flutter and Next.js examples: `references/platform-implementations.md`.
- Follow the relevant platform's accessibility, focus, and haptic conventions before adding shared button behavior.
