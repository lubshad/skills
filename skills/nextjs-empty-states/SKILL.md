---
name: nextjs-empty-states
description: Use when implementing Next.js loading, empty, no-results, error, or retry states.
---

# Next.js Empty States

Read `frontend-ui-states.md`. Use `src/components/ui/EmptyState.tsx`; features pass icon/title/copy/actions, while the component owns token-based layout/styles. Pair with existing `SectionHeader` when it already owns title/top-right action. Document materially different states as explicit component exceptions.

## Verification

Check shared component reuse, token styling, and applicable UI states.
