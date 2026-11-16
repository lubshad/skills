---
name: frontend-device-layout
description: Use when changing device-class layouts, responsiveness, scroll ownership, safe areas, admin density, or PWA/mobile fallbacks.
---

# Device Layout

Design by class, scale within class, and reflow at class boundaries or unreadable content—not through zoom/transforms, clipping, overlap, or hidden primary actions. Keep fixed-format controls stable across labels/icons/hover/loading; wrap/truncate with clear context or constrain text widths.

- Mobile: one-column, touch-first vertical flows, reachable/sticky actions and fullscreen complex tasks.
- Tablet: retain desktop hierarchy with fewer columns and touch-friendly spacing.
- Desktop/admin: dense scanning/comparison, stable navigation, visible controls, keyboard/mouse use and persistent toolbars/footers. Narrow fallback does not replace the desktop-first workflow.

## Scroll ownership

Document pages scroll naturally; PWA installation is not a fixed-shell mandate. Bounded app shells stay within available viewport, scrolling only named content regions while headers/navigation/actions stay outside. Long content, short landscape, and keyboards cannot strand focus/actions. Preserve user zoom/panning even with locked document scrolling. Adapters own viewport/overflow/keyboard syntax.

Admin tables fill shell space with top controls/pagination reachable. Desktop tab pages change through visible tabs, not horizontal swipe/drag; gestures are narrow-screen fallback only.

## Safe areas, once

For prototypes/production/browser/standalone, clear **content and controls**, not the shell: backgrounds/hero/media/backdrops remain edge-to-edge. Derive native runtime top/bottom/left/right insets with zero fallback, naturally updating by orientation/mode; no device-name/universal offsets.

Consume each inset once. Flowing headers/content inherit their spacer/parent clearance; fixed/absolute controls bypass flow and need own edge offsets from the same source plus intended gap, unless their containing block is already inset. Audit profile/menu/back, camera previews, notices, nav/actions, media controls, and landscape sides.

Simulated profile insets/OS chrome belong only to desktop previews; actual mobile uses native values. Next.js uses `nextjs-responsive-scaling.md`; Flutter uses matching layout adapters.

## Verification

Check zero/nonzero insets, portrait/landscape, browser/standalone, flow and overlay clearance exactly once, unchanged shell/background bounds, reachable top/bottom/side actions, and no clipping/document overflow. Injected insets support regression checks but do not replace real-device verification.
