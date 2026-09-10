---
name: nextjs-responsive-scaling
description: Use when changing Next.js responsive layout, CSS tokens, viewport sizing, scroll ownership, safe areas, or prototype and production PWA shells.
---

# Next.js Responsive Layout And Scaling

Read `frontend-device-layout.md` first; it owns device-class, scroll-surface, and safe-area behavior. This implementation adapter applies to all Next.js apps, including prototypes and production PWAs. Also read `frontend-mobile-app-prototyping.md` only when a desktop review/device-frame presentation is involved.

For `next_apps/masarnext/`, also read [Masar conventions](references/masar-conventions.md). Check the current project's instructions and installed Next.js documentation before changing framework APIs. This skill covers PWA layout, not service workers, offline caching, installation, push notifications, or update lifecycles.

## Core Rule

Keep the root font size stable across viewport sizes. Prefer `font-size: 100%` (normally 16px) so browser default-text preferences are respected. Preserve an explicit existing project constraint rather than silently changing its entire design scale; document and test any migration. Do not shrink the root font to fit content or calculate it from viewport width.

## Project Conventions

- Inspect the existing token source, global styles, component styles, and breakpoints before editing. Do not impose Masar's conventions on another project.
- Reuse spacing, sizing, radius, and typography tokens; prefer rem-based text and spacing where consistent with the project. Add genuinely shared tokens to the existing token source, not necessarily `globals.css`.
- Use `calc()` with tokens for derived gaps/widths; do not hardcode token-derived constants.
- Use `clamp()`, `min()`, `max()`, percentages, and flexible grid tracks for genuinely fluid values.
- Keep readable content constrained with a max width instead of stretching it across wide screens.
- Pixels are valid for borders, device-frame geometry, established breakpoints, and other intentional fixed dimensions. Avoid arbitrary values that bypass the design system, not pixel units themselves.
- Keep fixed-format controls stable when changing labels, icons, hover states, or loading states would otherwise shift layout.

## Component Responsiveness

- Use the project's existing device-class breakpoints for page and shell layout; do not duplicate root-font rules in components.
- Use container queries when a reusable component responds to its allocated width rather than the viewport.
- Add a new viewport breakpoint when content or interaction needs it, and document why the existing breakpoints are insufficient.
- Prefer grid or flex reflow over hiding content. Do not hide primary actions to make a layout fit.
- Allow text to wrap where practical. Use truncation only when the surrounding UI preserves enough context to identify the value.

## Pages And App Shells

- **Document pages:** retain natural document scrolling. Use `min-height: 100vh` followed by `min-height: 100svh` for a stable minimum viewport when useful; allow long content to grow. Do not lock the document simply because a site is installable.
- **Bounded app shells:** use `height: 100vh` followed by `height: 100dvh` at the shell-height owner. Give the root/wrapper chain a definite height and use `height: 100%` for nested wrappers instead of repeating viewport units. Set `min-height: 0` on nested flex/grid children and `min-width: 0` where content could force horizontal overflow.
- Scope document overflow/overscroll locking to bounded app surfaces. Keep route shells non-scrolling; use `overflow-y: auto` and contained overscroll on explicit content regions. Place persistent headers/navigation outside those regions. Restore normal scrolling on document routes.
- In installed standalone mode, consider a `100lvh` override only when testing demonstrates a launch-time jump with dynamic viewport sizing. Keep `100dvh` in normal browser mode; do not use the large viewport unconditionally behind expanded browser chrome.
- Prefer CSS viewport sizing over capturing `window.visualViewport.height` at startup; initial iOS standalone measurements may be transient. Use VisualViewport listeners only for a demonstrated keyboard/overlay need, with cleanup and resize handling, not as the default shell-sizing mechanism.
- Diagnose bottom gaps before adding inset height to the document. An iOS-specific background extension is a scoped, verified workaround, not a universal `viewport height + bottom inset` rule; ensure it does not introduce overflow or move bottom controls offscreen.
- With the software keyboard open, focused fields and primary form actions must remain reachable in the intended scroller. Do not treat keyboard height as a safe-area inset or assume `dvh` always follows keyboard visibility.

## Safe-Area Implementation

- Implement the shared safe-area contract with inherited CSS custom properties such as `--content-safe-top: env(safe-area-inset-top, 0px)`, and equivalent bottom/left/right values where needed. Defining these on a shell does not mean padding or moving that shell.
- An in-flow header or dedicated non-shrinking spacer consumes top clearance once. Absolute/fixed controls anchored to the viewport or full-bleed screen use `top: calc(var(--content-safe-top) + var(--control-gap))`; controls inside an already-inset containing block must not add the inset again. Use corresponding edge properties for bottom and landscape-side controls.
- Keep full-bleed backgrounds and media outside inset content containers. Do not add safe-area padding to the root shell as a shortcut for fixing individual controls.
- In desktop device previews, override the same custom properties from the selected device profile only within the preview scope. Actual-device layouts use `env()` values without user-agent detection or hardcoded phone padding.
- For edge-to-edge rendering, use Next.js viewport metadata with `viewportFit: "cover"`. For translucent iOS standalone status bars, use `appleWebApp.statusBarStyle: "black-translucent"` in metadata and let the active screen background paint behind the safe area. Check the installed Next.js metadata documentation before editing exports.

## Accessibility

- Keep interactive targets at least `2.75rem` by `2.75rem` unless the control is part of a denser desktop-only surface.
- Layout must remain usable at 200% browser zoom and with increased default text size.
- Do not reduce the root font size to make content fit.
- Do not disable user zoom in viewport metadata.
- Preserve visible keyboard focus, logical source order, and reachable actions after responsive reflow.
- Motion used during responsive transitions must respect `prefers-reduced-motion`.
- Document scroll locking must not disable pinch zoom or visual-viewport panning; avoid blanket `touch-action: none`.
- For `next/image`, provide accurate `sizes` for responsive sources, reserve dimensions or an aspect ratio, and verify images cannot force overflow.

## Anti-Patterns

- Arbitrary dimensions or one-off breakpoints that bypass established project conventions.
- Viewport-width formulas applied to the root font size.
- CSS `zoom` or `transform: scale()` to squeeze product layouts into a viewport. Exception: uniformly scaling the entire desktop review device, with reserved layout dimensions, as defined in `frontend-mobile-app-prototyping.md`.
- Fixed heights for text-heavy content that can wrap or grow.
- `100vh` as the only app-shell height when dynamic browser chrome matters; it remains valid as a compatibility fallback.
- Clipped text, overlapping controls, or horizontal page scrolling as responsive fallbacks.

## Verification

Choose coverage based on the affected surface and the project's actual breakpoints. For shared layout changes, cover narrow mobile (for example 360px), a typical phone, tablet, desktop, and both sides of every changed breakpoint. For device previews, also use the prototyping skill's viewport matrix. Masar-specific widths are in the reference.

- Confirm computed styles and actual layout bounds, not just screenshots. State which checks were simulated and which used a real device.
- Portrait and landscape on a narrow touch viewport.
- Browser zoom at 200% and increased browser default text size, checked separately, with no lost actions or unintended two-dimensional page scrolling.
- Long labels, translated text, validation errors, loading states, and empty states.
- The shared safe-area verification from `frontend-device-layout.md`, including in-flow headers, absolute/fixed controls, and browser versus standalone modes. Override CSS inset variables during browser tests and confirm shell/background bounds stay unchanged; also verify native insets on a real device.
- Responsive images do not overflow and request an appropriate source size.
- For bounded shells: only designated regions scroll; headers/navigation remain stationary; short viewports and long content do not expand the root. For document pages: natural scrolling remains available.
- For PWAs: test initial launch, browser chrome expansion/collapse, orientation changes, standalone mode, and keyboard open/close on forms. Verify focused fields and actions remain reachable and no launch-time bottom gap is introduced.

Desktop retains a fixed design scale so wide screens gain usable space instead of enlarging the entire interface. Mobile and tablet adapt through token overrides, flexible dimensions, and deliberate reflow rather than whole-page scaling.
