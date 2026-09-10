# Masar Responsive Conventions

Applies only to `next_apps/masarnext/`. Inspect the current code before editing; these conventions must not be imposed on other Next.js apps.

## Tokens And Breakpoints

- The project's documented token and breakpoint source is `src/app/globals.css`.
- Reuse its rem-based spacing, sizing, typography, and radius tokens. Add shared tokens there when no existing token fits.
- The established root size is `16px`. Preserve it during unrelated layout fixes. A move to `100%` to honor default-text preferences is an explicit accessibility migration requiring project-wide verification, not an incidental change.

| Class | Range | Reference Width |
|-------|-------|-----------------|
| Mobile | <=767px | 390 |
| Tablet | 768-1023px | 820 |
| Desktop | >=1024px | 1440 |

Reflow at device-class boundaries without viewport-driven root-font scaling. Use fluid dimensions within classes where content benefits.

## Verification

- Desktop widths: 1280, 1440, 1600, 1920.
- Tablet widths: 768, 820, 1000, 1023.
- Mobile widths: 360, 390, 414.
- Boundary pairs: 767/768 and 1023/1024.
- Run the main skill's applicable safe-area, scrolling, keyboard, zoom, and text-size checks. Report any existing fixed-root limitation rather than claiming default-text preference support without testing it.
