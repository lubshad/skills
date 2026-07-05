---
name: frontend-device-layout
description: Use when changing desktop, tablet, mobile, responsive behavior, proportional scaling, admin density, or mobile fallback decisions.
---

Follow these device-layout rules for all user-facing frontend UI, regardless of framework.

## Device Classes

- **Mobile:** narrow phones. Prioritize one-column flows, touch targets, vertical scanning, sticky primary actions where useful, and fullscreen task surfaces for complex forms.
- **Tablet:** medium-width touch screens. Preserve the main desktop information hierarchy where possible, but reduce columns and avoid cramped controls.
- **Desktop:** wide screens and browser-hosted admin surfaces. Prioritize scan density, stable navigation, visible controls, table/list comparison, keyboard/mouse ergonomics, and persistent footers/toolbars.

## Responsive Rules

- Design by device class first; scale within a class before changing layout.
- Reflow only when crossing a device-class boundary or when content would otherwise become unreadable.
- Do not solve responsive issues with transform scaling, browser zoom, clipped text, overlapping controls, or hidden primary actions.
- Keep fixed-format controls stable with explicit dimensions or constraints so hover states, labels, icons, loading states, and dynamic content do not shift layout.
- Text must fit its container at mobile, tablet, and desktop widths. Use wrapping, truncation with clear context, or constrained widths.

## Admin Surfaces

- Admin/back-office panels are desktop-first even when browser-hosted.
- Provide responsive fallbacks for narrow widths, but optimize the primary workflow for laptop/desktop operators.
- Listing and table surfaces should fill the available shell area; keep top controls and pagination reachable while rows scroll.
- Tab content views on desktop must not be horizontally swipeable/draggable between pages. Users should change tabs through the visible tab controls; swipeable tab-page gestures are only a narrow-screen fallback.

## Platform Adapters

- Next.js spacing/sizing implementation details live in `nextjs-responsive-scaling.md`.
- Flutter layout/widget implementation details live in the relevant `flutter-*` skill.
