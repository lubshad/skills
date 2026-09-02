---
name: nextjs-responsive-scaling
description: Use when changing Next.js CSS, rems, tokens, proportional scaling, responsive behavior, or device-class layout in masarnext.
---

# Next.js Responsive Scaling

Follow these Next.js CSS scaling rules in `next_apps/masarnext/`. Read `frontend-device-layout.md` first; it owns device-class behavior.

## Core Rule

Keep the root font size stable at `16px`. Use rem-based tokens from `globals.css` for layout, spacing, radii, and typography, then reflow or override tokens at device-class boundaries. Do not scale the entire interface through the root font size, CSS `zoom`, or transforms.

## Device Classes

| Class | Range | Reference width | Root font size |
|-------|-------|-----------------|----------------|
| Mobile | <=767px | 390 | `16px` |
| Tablet | 768-1023px | 820 | `16px` |
| Desktop | >=1024px | 1440 | `16px` |

The canonical breakpoints and root size live in `src/app/globals.css`. Do not duplicate root-size rules in components. Reflow at class boundaries; use fluid values within a class only where the content benefits from them.

## Token Rules

- Use existing `rem` tokens for spacing, sizing, radius, and font-size.
- Add new tokens in `globals.css` when no existing token fits.
- Use `calc()` with tokens for derived gaps/widths; do not hardcode token-derived constants.
- Use `clamp()`, `min()`, `max()`, percentages, and flexible grid tracks for genuinely fluid values.
- Keep readable content constrained with a max width instead of stretching it across wide screens.
- Fixed-pixel concepts such as 1px borders, hairlines, and intentionally oversized sentinel radii may remain in pixels.
- Keep fixed-format controls stable when changing labels, icons, hover states, or loading states would otherwise shift layout.

## Component Responsiveness

- Use the canonical media-query classes for page and shell layout.
- Use container queries when a reusable component responds to its allocated width rather than the viewport.
- Add a new viewport breakpoint only when content cannot remain readable using the canonical classes, and document the reason beside the query.
- Prefer grid or flex reflow over hiding content. Do not hide primary actions to make a layout fit.
- Allow text to wrap where practical. Use truncation only when the surrounding UI preserves enough context to identify the value.

## Mobile And PWA Layout

- Use `min-height: 100svh` for a stable initial viewport and `100dvh` where a surface should follow browser chrome changes. Include a suitable fallback when required by the supported browser range.
- Apply `env(safe-area-inset-*)` to edge-aligned fixed or sticky surfaces when they can run in standalone mode or behind a device cutout.
- Keep interactive targets at least `2.75rem` by `2.75rem` unless the control is part of a denser desktop-only surface.
- Verify narrow landscape layouts as well as portrait layouts; do not assume width implies device orientation.
- For `next/image`, provide accurate `sizes`, preserve an aspect ratio, and avoid serving desktop-sized assets to narrow screens.
- This skill owns PWA layout concerns only. Manifests, service workers, offline caching, installation, push notifications, and update lifecycles require separate implementation guidance.

## Accessibility

- Layout must remain usable at 200% browser zoom and with increased default text size.
- Do not reduce the root font size to make content fit.
- Do not disable user zoom in viewport metadata.
- Preserve visible keyboard focus, logical source order, and reachable actions after responsive reflow.
- Motion used during responsive transitions must respect `prefers-reduced-motion`.

## Anti-Patterns

- Raw px for padding, margin, width, height, font-size, gap, or border-radius in new code.
- One-off breakpoint overrides with px values.
- Viewport-width formulas applied to the root font size.
- CSS `zoom` or `transform: scale()` to make layouts fit.
- Fixed heights for text-heavy content that can wrap or grow.
- `100vh` for full-screen mobile surfaces when dynamic browser chrome matters.
- Clipped text, overlapping controls, or horizontal page scrolling as responsive fallbacks.

## Verification

Check touched pages at:

- Desktop: 1280, 1440, 1600, 1920.
- Tablet: 768, 820, 1000, 1023.
- Mobile: 360, 390, 414.

Also verify:

- Both sides of each class boundary: 767/768 and 1023/1024.
- Portrait and landscape on a narrow touch viewport.
- Browser zoom at 200% with no lost actions or two-dimensional page scrolling.
- Long labels, translated text, validation errors, loading states, and empty states.
- Sticky and fixed controls with mobile safe-area insets.
- Responsive images do not overflow and request an appropriate source size.

Desktop retains a fixed design scale so wide screens gain usable space instead of enlarging the entire interface. Mobile and tablet adapt through token overrides, flexible dimensions, and deliberate reflow rather than whole-page scaling.
