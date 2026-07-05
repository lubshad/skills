---
name: frontend-interaction-patterns
description: Use when designing frontend destructive actions, confirmations, modals, Escape key dialog closing, recovery flows, action language, or refresh behavior.
---

Follow these frontend interaction rules across all UI platforms.

## Platform Strategy

- Frappe is a headless backend/API provider for user-facing products.
- User-facing interfaces are built with dedicated frontend frameworks such as Flutter or Next.js.
- Frappe Desk customizations are for admin/back-office operations only.

## Destructive Actions

- Any destructive action that removes user data or records requires explicit confirmation before the request is sent.
- Confirmation copy should identify the affected record when that context is available.
- Do not use browser-native alerts/confirm dialogs for product UI.
- If a confirmed destructive action fails, show a product-styled error with a recovery action.
- Keep or restore the affected item after a failed destructive action so the user is not left believing the record was deleted.

## Modal And Action Consistency

- Reuse established modal/dialog/sheet patterns rather than one-off layouts.
- Modal headers, close buttons, spacing, and action areas should match the product style unless there is a clear reason to diverge.
- On mobile, complex form-oriented modals should use fullscreen task surfaces with sticky header and sticky bottom actions.
- In desktop view, any active modal, dialog, sheet, or overlay must close/dismiss when the user presses the `Escape` (Esc) key (see Focus/Nested behaviors below).

## Modal Keyboard Accessibility (Escape to Close)

- **Escape Key Dismissal**: Any active dialog or overlay on desktop must dismiss on pressing the `Escape` key.
- **Focus Management**:
  - **Initial Focus**: On open, move focus inside the dialog (wrapper or first interactive element) to capture keyboard events immediately.
  - **Restore Focus**: On close, restore focus to the trigger element that opened the dialog.
- **Nested Modals**: Pressing `Escape` must only close the topmost/most recently active overlay, returning focus to the underlying dialog context.
- **Unsaved Changes**: If a dialog contains a form with unsaved changes, pressing `Escape` must trigger a confirmation dialog to prevent data loss (which itself can be cancelled using `Escape`).

## Refresh And Invalidation

- When one saved change must refresh multiple mounted components without navigation, use `event-based-refresh.md` or the platform's feature-local state/event mechanism.
