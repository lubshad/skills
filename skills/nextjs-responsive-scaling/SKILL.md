---
name: nextjs-responsive-scaling
description: Use when changing Next.js CSS, rems, tokens, proportional scaling, responsive behavior, or device-class layout in masarnext.
---

Follow these Next.js CSS scaling rules in `next_apps/masarnext/`. Read `frontend-device-layout.md` first; it owns device-class behavior.

## Core Rule

Use rem-based tokens from `globals.css` for layout, spacing, radii, and typography. Do not use raw px for scalable layout values.

## Reference Widths

| Class | Range | Reference width | Root font-size formula |
|-------|-------|-----------------|-------------------------|
| Mobile | <=767px | 390 | `clamp(14px, 100vw * 16 / 390, 20px)` |
| Tablet | 768-1023px | 820 | `clamp(15px, 100vw * 16 / 820, 20px)` |
| Desktop | >=1024px | 1440 | `clamp(14px, 100vw * 16 / 1440, 22px)` |

These rules live in `src/app/globals.css` under proportional scaling. Do not duplicate them elsewhere.

## Token Rules

- Use existing `rem` tokens for spacing, sizing, radius, and font-size.
- Add new tokens in `globals.css` when no existing token fits.
- Fixed-pixel concepts such as 1px borders/hairlines may remain px.
- Use `calc()` with tokens for derived gaps/widths; do not hardcode token-derived constants.

## Anti-Patterns

- Raw px for padding, margin, width, height, font-size, gap, or border-radius in new code.
- One-off breakpoint overrides with px values.
- CSS `zoom` or `transform: scale()` to make layouts fit.
- New breakpoints outside the canonical mobile/tablet/desktop classes without explicit approval.

## Verification

Check touched pages at:
- Desktop: 1280, 1440, 1600, 1920.
- Tablet: 768, 820, 1000.
- Mobile: 360, 390, 414.

Within a device class, layouts should scale proportionally. Reflow is expected only across class boundaries or when needed for readability.
