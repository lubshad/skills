---
name: nextjs-empty-states
description: Use when implementing Next.js loading, empty, no-data, no-results, error, or retry states.
---

Follow these Next.js implementation rules for empty/no-data states. Read `frontend-ui-states.md` first; it owns UI state behavior.

## Shared Component

- Use `src/components/ui/EmptyState.tsx` for standard empty states.
- Pass only icon, title, descriptive copy, and action props from the feature.
- Keep layout and styling in the shared component.
- Prefer pairing `EmptyState` with `SectionHeader` when the screen already has a title and top-right action.

## Styling

- Use design tokens and shared CSS variables.
- If a section needs a materially different empty state, treat it as an explicit exception and document the reason in the component.
