---
name: frontend-device-layout
description: Use when changing desktop, tablet, mobile, responsive behavior, safe areas, prototype or production PWA layout, proportional scaling, admin density, or mobile fallback decisions.
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

## Scroll Surfaces

- Choose scroll ownership from the product surface, not installation status. Document pages retain natural page scrolling; installing a PWA does not automatically make every route a fixed app shell.
- Bounded app surfaces keep their shell within the available viewport and scroll only designated content regions. Persistent headers, navigation, and actions remain outside those scrollers.
- Long content, short landscape viewports, and the software keyboard must not make focused fields or primary actions unreachable. Preserve user zoom and panning even when document scrolling is locked.
- Platform adapters own viewport units, wrapper sizing, overflow styles, and keyboard handling.

## Safe Areas

These rules apply to prototypes and production apps, including browser and installed standalone PWA layouts.

- Apply clearance to content and interactive controls, not padding or offsets on the entire shell. Backgrounds, hero images, video, and overlay backdrops remain edge-to-edge.
- Derive clearance from runtime device/platform insets with a zero fallback, not device-name detection or a universal phone offset. Recompute naturally as orientation or browser mode changes.
- Apply each inset once. Headers or content already following an inset-aware spacer or parent must not receive duplicate clearance.
- Absolute/fixed controls bypass normal-flow spacers. Share the same clearance source, but apply it to those controls' own edge offsets plus their intended content gap.
- Audit profile back/menu actions, call camera previews, top notices, bottom navigation/actions, and media controls, not only ordinary headers. Respect left/right insets in landscape as well as top/bottom insets.
- Keep simulated device-profile insets scoped to desktop previews. Actual devices use native insets and must not retain simulated operating-system chrome or preview clearance.

## Admin Surfaces

- Admin/back-office panels are desktop-first even when browser-hosted.
- Provide responsive fallbacks for narrow widths, but optimize the primary workflow for laptop/desktop operators.
- Listing and table surfaces should fill the available shell area; keep top controls and pagination reachable while rows scroll.
- Tab content views on desktop must not be horizontally swipeable/draggable between pages. Users should change tabs through the visible tab controls; swipeable tab-page gestures are only a narrow-screen fallback.

## Platform Adapters

- Next.js spacing/sizing implementation details live in `nextjs-responsive-scaling.md`.
- Flutter layout/widget implementation details live in the relevant `flutter-*` skill.

## Verification

- Test zero and nonzero safe-area insets, portrait and landscape, and both browser and installed standalone modes.
- Confirm ordinary headers and absolute/fixed overlays receive clearance exactly once, while shell/background bounds remain unchanged.
- Confirm top controls, bottom actions, and landscape side controls stay reachable without clipping or document overflow.
- Injected test insets are useful for layout regression checks but do not replace real-device browser and standalone verification.
