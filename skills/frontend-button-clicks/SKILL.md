---
name: frontend-button-clicks
description: Use when implementing button clicks, form submission, or generic user actions that may need focus management or haptic feedback.
---

# Frontend Button Clicks

## Core Rules

For touch-first submission, context changes, sheets, or navigation, use this sequence when helpful:

1. **Unfocus** only if the active input is no longer relevant, so the keyboard cannot obscure the next surface.
2. **Confirm by touch** with light/medium haptics on supported devices for meaningful submit, save, destructive confirmation, or navigation actions. This acknowledges slow-network taps.
3. **Execute** the intended action.

Do not blur keyboard-focused controls for inline actions such as toggles, pagination, filters, or retry. Do not require vibration for web, keyboard activation, or high-frequency controls. Preserve visible keyboard focus unless the interaction deliberately moves the user elsewhere.

## Implementation References

- Flutter and Next.js examples: `references/platform-implementations.md`.
- Follow the relevant platform's accessibility, focus, and haptic conventions before adding shared button behavior.
