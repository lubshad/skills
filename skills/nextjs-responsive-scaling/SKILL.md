---
name: nextjs-responsive-scaling
description: Use when changing Next.js responsive CSS, tokens, viewport/scroll ownership, safe areas, or PWA shells.
---

# Next.js Responsive Layout

Read `frontend-device-layout.md` first, then [the layout contract](LAYOUT-CONTRACT.md) before CSS/shell changes. It owns viewport units, inset application, accessibility and test coverage. Masar also reads `references/masar-conventions.md`; do not impose Masar tokens on other projects. Browser review framing additionally uses `frontend-mobile-app-prototyping.md`; ordinary production PWAs do not.

## Invariants

- Stable root text scale (prefer 100%), existing tokens/breakpoints, readable constrained content, and deliberate device-class reflow. No root-font viewport formulas or product transform/zoom squeezing.
- Document pages scroll naturally. Bounded shells own a definite viewport height and only designated content scrollers; headers/navigation stay outside. PWA installation alone does not justify document locking.
- CSS/native inset variables clear content once, not shell/background bounds. Fixed controls need their own correctly scoped edge clearance; preview-device overrides stay desktop-only.
- Keyboard height is not safe area; keep fields/actions reachable. Native viewport listeners/large-viewport/background workarounds need demonstrated need and cleanup, not blanket adoption.
- Keep zoom/panning, logical focus/order, reduced motion, responsive image dimensions/sizes, and accessible targets. Never hide primary controls to fit.

## Verification

Use actual bounds/computed styles and the contract's breakpoint/mobile/tablet/desktop, portrait/landscape, 200% zoom/default text, long/state content, inset/browser/standalone, scroller, launch/chrome/orientation/keyboard checks. Mark real-device versus simulated evidence separately. This skill covers layout, not unrelated PWA offline/push/update infrastructure.
